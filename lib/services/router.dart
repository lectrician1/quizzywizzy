import 'dart:collection';

/// Needed to create views
import 'package:flutter/material.dart';

/// Firestore
/// Needed for storing hierarchy data locally
import 'package:cloud_firestore/cloud_firestore.dart';

/// Routing constants
import 'package:quizzywizzy/services/routing_constants.dart';

/// Views
import 'package:quizzywizzy/views/add_question.dart';
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/single_question.dart';
import 'package:quizzywizzy/views/study_set.dart';
import 'package:quizzywizzy/views/route_not_found.dart';

/// A class that stores a list/stack of path segments (called [hierarchy]).
///
/// e.g. [courses, AP Calculus BC]
///
/// It notifys any listeners whenever there is a change in the [hierarchy].
///
/// It is used for requested and curren
class AppStack extends ChangeNotifier {
  List<String> _hierarchy;
  List<String> get hierarchy => _hierarchy;

  PseudoPage _pseudoPage = PseudoPage.none;
  PseudoPage get pseudoPage => _pseudoPage;

  AppStack({@required List<String> hierarchy}) : _hierarchy = hierarchy;

  /// Set a new hierarchy
  void setStack(List<String> otherHierarchy) {
    _hierarchy = List.from(otherHierarchy);
    _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  /// Set a new hierarchy using a existing AppStack
  void copyCurrStack(AppStack curr) {
    _hierarchy = List.from(curr._hierarchy);
    _pseudoPage = curr._pseudoPage;
  }

  /// Set a new hierarchy using a existing AppStack
  void copyRequestedStack(AppStack requested) {
    _hierarchy = List.from(requested._hierarchy);
    _pseudoPage = requested._pseudoPage;
  }

  /// Remove a page from the hierarchy
  void pop() {
    if (_pseudoPage == PseudoPage.none)
      _hierarchy.removeLast();
    else
      _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  /// Add a page to the hierarchy and view stack
  void push(String pathSegment) {
    _hierarchy.add(pathSegment);
    _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  void pushPseudo(PseudoPage page) {
    _pseudoPage = page;
    notifyListeners();
  }
}

/// A class that updates the [Navigator] based on updates to [_requested].
///
/// Use Get.find<AppRouterDelegate>() to get the current instance of this class (make sure to include <>).
class AppRouterDelegate extends RouterDelegate<AppStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppStack> {
  final GlobalKey<NavigatorState> navigatorKey;

  /// A stack that calls [_updateStack] whenever there is a change in hierarchy.
  ///
  /// It accomplishes this by adding [_updateStack] as a listener.
  /// This is also used by [currentConfiguration] to send an [AppStack] to [AppRouteInformationParser] to parse into the current url (not always the same as the currently rendered pages).
  AppStack _requested;

  /// A stack that represents the currently rendered pages.
  AppStack _curr;

  /// Represents any additional page.
  ///
  /// See [AdditionalPage] enum for more details.
  AdditionalPage _additionalPage;

  /// Represents whether or not [_updateStack] has already been called.
  bool _loading;

  /// Local storage for hierarcy documents.
  ///
  /// Key is the reference to the hierarcy document that has been visited
  ///
  /// Value is the document data stored in a accessible [List]
  HashMap<String, List<Map<String, dynamic>>> _visitedDocuments;

  /// Local storage for hierarcy collections.
  ///
  /// Key is the reference to the hierarcy collection that *can* be visited
  ///
  /// Value is the Firestore [CollectionReference]
  HashMap<String, CollectionReference> _visitedCollections;

  AppStack get currentConfiguration => _requested;

  /// Main constructor that initializes all of the needed AppStacks for the router
  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _requested = AppStack(hierarchy: []),

        /// Courses needs to be in the current heirarchy or else getPages will never know what the "first page" is.
        /// This is temporary until an actual homepage is created and getPages can account for no first hierarchy
        _curr = AppStack(hierarchy: ["courses"]),
        _additionalPage = AdditionalPage.none,

        /// Initialize local storage
        _visitedDocuments = new HashMap(),
        _visitedCollections = new HashMap(),
        _loading = false {
    /// Add [_updateStack] as listener function
    /// [_updateStack] is called every time [_requested] is changed
    _requested.addListener(_updateStack);

    // Add root collection reference to
    _visitedCollections["/courses"] =
        FirebaseFirestore.instance.collection(collectionNames[0]);
  }

  /// Build the [Navigator]-based router
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.unmodifiable(_getPages()),
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  bool canPop() {
    return _additionalPage != AdditionalPage.none ||
        _requested.hierarchy.length > 1;
  }

  /// pops [_requested] stack. All calls will be ignored if [_loading] == true.
  void pop() {
    if (_loading) return;
    if (_additionalPage != AdditionalPage.none) {
      _additionalPage = AdditionalPage.none;
      _requested.copyCurrStack(_curr);
      notifyListeners();
    } else
      _requested.pop();
  }

  /// pushes a path segment on to [_requested] stack. All calls will be ignored if [_loading] == true.
  void push(String pathSegment) {
    if (_loading) return;
    _requested.push(pathSegment);
  }

  /// pushes a pseudo path on to [_requested] stack. All calls will be ignored if [_loading] == true.
  void pushPseudo(PseudoPage pseudoPage) {
    if (_loading) return;
    _requested.pushPseudo(pseudoPage);
  }

  /// updates [_requested] stack. All calls will be ignored if [_loading] == true.
  void setStack(List<String> hierarchy) {
    if (_loading) return;
    _requested.setStack(hierarchy);
  }

  /// Updates the [_curr] stack.
  ///
  /// Runs whenever a page is requested
  ///
  /// DETAILED DECRIPTION:
  ///
  /// Rebuilds the navigator (calling [_getPages] in the process) whenever it changes [_status]. It does so whenever it calls [notifyListeners].
  /// (In Navigator 2.0, a pre-programmed Router class listens to [AppRouterDelegate] and calls the delegate's [build] whenever the Router is notified.)
  ///
  /// All calls will be ignored if [_loading] == true. [_loading] will be set to true during this method.
  ///
  /// This method is in charge of evaluating whether or not [AppStatus.notFound] based on [_requested].
  /// If [AdditionalPage.none], then [_curr] replaces its hierarchy with [_requested]'s hierarchy.
  /// Otherwise, [_curr] stays the same.
  Future<void> _updateStack() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    /// Always set notFound as false when updateStack is called.
    bool notFound = false;

    /// Always set that there is no additional page when updateStack is called.
    _additionalPage = AdditionalPage.none;

    /// Represents the hierarchy
    /// e.g. [courses, AP Calculus BC]
    /// Also a simplification variable
    List<String> _hierarchy = _requested.hierarchy;

    /// Check the first value of the hierarchy
    switch (_hierarchy[0]) {

      /// If "courses" is the first value.
      /// e.g. studysprout.org/courses
      case "courses":

        /// Loop through each of the possible heierarchy levels to check
        /// if their Firestore collections and documents have been locally stored.
        for (int i = 0; i < _hierarchy.length; i++) {
          /// Get the possible Firestore paths for each of the possible hierarchy collections
          /// e.g. /courses, /courses/AP Calculus BC, /courses/AP Calculus/units/Series
          String collection = getRoute(_hierarchy.sublist(0, i + 1), "");

          /// ---
          /// Following #s represent how the for loop works
          /// when the coures page is first needed
          /// ---

          /// 1. From line 141, [_visitedCollections] = {/courses: CollectionReference(courses)}
          /// so the root collection reference is already present.

          /// If local storage has a collection reference for the needed path
          /// e.g. /courses/AP Biology: CollectionReference(courses/cK93AhRq51tT4muADvaH/units)
          if (_visitedCollections.containsKey(collection)) {
            /// 2. Therefore, we just need to retreive the data for each of the documents
            /// in the collection to display the course names.
            ///
            /// There is no document for the /course root collection, but that is ok.

            /// If local storage DOES NOT have the document data for the needed path
            /// e.g. /courses/AP Biology: null
            if (!_visitedDocuments.containsKey(collection)) {
              /// 3. We're here to retreive all of the documents in the /courses collection
              /// [.get()] does this

              /// course, untit, topic name, icon, etc. can be displayed
              QuerySnapshot query = await _visitedCollections[collection].get();

              /// Decalare null existance of entry before adding the data
              _visitedDocuments[collection] = [];

              

              /// For each document...
              query.docs.forEach((doc) {
                /// 4. Get the documents for each of the courses (AP Calculus BC, AP Biology, etc.)
                
                /// Add the document data with it's corresponding path to the [_visitedDocuments] collection
                /// {/courses/AP Biology: [{name: Chemistry of life}]}
                _visitedDocuments[collection].add(doc.data());

                /// 5. Get the subcollection references for each of the course documents
                /// 
                /// How this works:
                /// _visitedCollections["/courses" + "/AP Calculus BC"] = subcollection with name "units" in the document
                /// _visitedCollections["/courses/AP Calculus BC"] = /courses/AP Calculus BC courseDocumentId/units/coursesubCollectionId

                /// Add the collection references with their new lower paths 
                /// for courses, units, and topics; but not subtopics 
                /// (they're just not needed)
                if (i + 1 < collectionNames.length)
                  _visitedCollections[
                          appendRoute(doc.data()["name"], collection)] =
                      doc.reference.collection(collectionNames[i + 1]);
              });
            }
          }

          /// If local storage DOES NOT have a collection reference for the needed path
          /// e.g. /courses/troll: null
          else {
            notFound = true;
          }
        }

        /// --- How the for loop works ---
        ///
        /// Notice:
        ///
        /// Anywhere requested in the hierarchy the courses page is needed
        /// because it acts as the page at the bottom of the view stack
        /// and all lower heierarcal data is dependent on collection references
        /// that are retreived before the lower heierarcal data is retrieved.
        ///
        /// ---
        ///
        /// This is demonstrated through the usage of the for loop.
        ///
        /// The for loop always starts with checking if the:
        /// 1. "/courses" collection reference exists
        /// 2. "/courses" collection documents' data exists
        ///
        /// If both are true, the for loop will proceed checking the path
        /// that includes the next level in the hierarchy.
        ///
        /// For example:
        ///
        /// IF
        /// _requested.hierarchy = [courses, AP Calculus BC]
        /// _hierarchy = [courses, AP Calculus BC]
        /// i = 1
        ///
        /// THEN
        /// collection = "/courses/AP Calculus BC"
        ///
        /// SO
        /// 1. Check if "/courses/AP Calculus BC" collection reference exists
        ///   It DOES exist because the reference was added when the "/courses"
        ///   document data was added.
        /// 2. Check if "/courses/AP Calculus BC" collection documents' data exists
        ///   It DOES NOT exist, so the data AND next collection references will
        ///   be added to local storage.
        ///
        /// The cycle can then repeat for the next level of the hierarcy.

        break;
      case "question":
        break;
      case "sproutset":
        break;
      case "user":
        break;
      default:
        notFound = true;
        break;
    }

    if (notFound) _additionalPage = AdditionalPage.notFound;

    if (_additionalPage == AdditionalPage.none)
      _curr.copyRequestedStack(_requested);
    _loading = false;

    notifyListeners();
  }

  /// Generates pages for the [Navigator] based on [_curr] and [_additionalPage]
  List<Page<dynamic>> _getPages() {
    // Page stack in order
    List<Page<dynamic>> pages = [];

    print(_curr.hierarchy);

    // /courses/apbc

    // Cases for handling the pages of each of the root paths

    // _curr.hierarchy = [courses, apbc]
    switch (_curr.hierarchy[0]) {
      case "courses":
        // Add heirarchy pages
        for (int i = 0; i < _curr.hierarchy.length; i++) {
          List hierarchy = _curr.hierarchy;
          String key = getRoute(hierarchy.sublist(0, i + 1), "");

          pages.add(MaterialPage(
              child: AppHomeView(
                  appHierarchy: hierarchy.sublist(1, i + 1),
                  queryData: _visitedDocuments[key])));
        }
        break;
      case "question":
        break;
      case "sproutset":
        break;
      case "user":
        break;
      default:
        print("oh");
        break;
    }

    // Handle creation of pseudo-pages (views without url segments).
    switch (_curr._pseudoPage) {
      case PseudoPage.none:
        break;
      case PseudoPage.addQuestion:
        pages.add(MaterialPage(child: AddQuestionView()));
        break;
      case PseudoPage.singleQuestion:
        pages.add(MaterialPage(child: SingleQuestionView()));
        break;
    }

    // Show loading view if page is loading.
    if (_loading) {
      pages += [
        MaterialPage(
            //key: ValueKey(getRoute(_curr.hierarchy, "loading")),
            child: LoadingView())
      ];
      return pages;
    }

    switch (_additionalPage) {
      case AdditionalPage.none:
        break;
      case AdditionalPage.notFound:
        pages += [
          MaterialPage(
              //key: ValueKey(getRoute(_curr.hierarchy, "not-found")),
              child: RouteNotFoundView(name: Uri.base.toString()))
        ];
        break;
    }
    return pages;
  }

  @override
  Future<void> setNewRoutePath(AppStack stack) async {
    if (_loading) return;
    if (stack.hierarchy.length > 0) _requested.setStack(stack.hierarchy);
  }
}

/// A class that parses urls into [AppStack]s, and [AppStack]s into urls.
class AppRouteInformationParser extends RouteInformationParser<AppStack> {
  @override
  Future<AppStack> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    return AppStack(hierarchy: uri.pathSegments);
  }

  @override
  RouteInformation restoreRouteInformation(AppStack page) {
    RouteInformation route;
    route = RouteInformation(location: getAppRoute(page.hierarchy));
    return route;
  }
}

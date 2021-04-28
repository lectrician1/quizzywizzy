/// Encode a inputted URI (URL) to lowercase and replace the spaces with dashes 
String encodeUri(String uri) {
  return uri.replaceAll(RegExp(' '), '-').toLowerCase();
}

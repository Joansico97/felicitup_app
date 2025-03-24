String extractFilePathFromFirebaseStorageUrl(String fullUrl) {
  final uri = Uri.parse(fullUrl);

  final pathSegments = uri.pathSegments;

  final int oIndex = pathSegments.indexOf('o');
  if (oIndex == -1 || oIndex == pathSegments.length - 1) {
    return '';
  }
  final List<String> extractedPathSegments = pathSegments.sublist(oIndex + 1);
  final String encodedFilePath = extractedPathSegments.join('/');

  return encodedFilePath;
}

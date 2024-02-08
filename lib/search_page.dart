import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final void Function(String) onSearchResultSelected;

  CustomSearchDelegate({required this.onSearchResultSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.toLowerCase() == 'kaduru') {
      _launchURL(
          'https://www.dilmahconservation.org/arboretum/plants-and-trees/divi-kaduru--a874c58b306213bbdcdfe68f963149ce.html');
    } else if (query.toLowerCase() == 'carambola') {
      _launchURL(
          'https://manoa.hawaii.edu/ctahr/pacificfoodguide/index.php/grown-from-the-ground/star-fruit/');
    }
    onSearchResultSelected(query); // Call the callback function
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Suggestions for: $query'),
    );
  }

  // Function to launch the specified URL
  _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(
          url,
          forceWebView:
              false, // Set to true if you want to force using the in-app browser.
          enableJavaScript: true, // Enable JavaScript for better functionality.
          headers: {}, // Additional headers if needed.
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}

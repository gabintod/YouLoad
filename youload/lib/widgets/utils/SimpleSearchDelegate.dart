import 'package:flutter/material.dart';

class SimpleSearchDelegate extends SearchDelegate {
  final Widget Function(BuildContext, String) resultsBuilder;

  SimpleSearchDelegate({required this.resultsBuilder});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return resultsBuilder(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }
}
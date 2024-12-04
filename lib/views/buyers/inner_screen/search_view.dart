import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/place.dart';
import '../../../provider/location_api.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        title: Text('Search Location', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SearchInjector(
        child: SafeArea(
          child: Consumer<LocationApi>(
            builder: (_, api, child) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: api.addressController,
                    decoration: InputDecoration(labelText: 'Search Location'),
                    onChanged: (query) {
                      print("Search query: $query");
                      api.handleSearch(query);
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Place>>(
                    stream: api.controllerOut,
                    builder: (context, snapshot) {
                      print("Stream data: ${snapshot.data}");
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No data address found'));
                      }
                      final data = snapshot.data!;
                      return Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final place = data[index];
                            return ListTile(
                              onTap: () {
                                // Return the selected address to the previous screen
                                Navigator.pop(context,
                                    '${place.name}, ${place.street}, ${place.country}');
                              },
                              title: Text('${place.name}, ${place.street}'),
                              subtitle: Text('${place.country}'),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchInjector extends StatelessWidget {
  final Widget child;

  const SearchInjector({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocationApi>(
      create: (_) => LocationApi(),
      child: child,
    );
  }
}

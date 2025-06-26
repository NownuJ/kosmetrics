import 'package:flutter/material.dart';
import 'product_list_page.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<String> categories = [
    'Ranking',
    'Toners',
    'Lotions',
    'Sunscreens',
    'Moisturisers',
    'Cleansers'
  ];

  String selectedCategory = 'Ranking';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory),
        bottom: selectedCategory == 'Ranking'
            ? PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                },
                child: Text("Age"),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text("Skin Type"),
              ),
            ],
          ),
        )
            : null,
      ),
      body: Row(
        children: [
          Container(
            width: 120,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category),
                  selected: selectedCategory == category,
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });

                    if (category != 'Ranking') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListPage(category: category),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: selectedCategory == 'Ranking'
                ? Center(
              child: Text(
                'to be continued',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
                : Container(),
          ),
        ],
      ),
    );
  }
}

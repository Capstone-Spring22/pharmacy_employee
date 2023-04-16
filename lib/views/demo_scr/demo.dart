import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/material.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FilledButton(
              onPressed: () {
                showModalExprollable(
                  context,
                  builder: (context) {
                    return Scaffold(
                      backgroundColor: Colors.grey,
                      body: ExprollablePageView(
                        itemCount: 5,
                        itemBuilder: (context, page) {
                          return ListView.builder(
                            controller: PageContentScrollController.of(context),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('Item#$index'),
                                tileColor: Colors.red,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: const Text("HIT"))),
    );
  }
}

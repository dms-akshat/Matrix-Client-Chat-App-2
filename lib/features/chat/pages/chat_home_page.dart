// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix_chat_app/features/chat/pages/user_chat.dart';
import 'package:matrix_chat_app/features/invite_user/pages/page_1.dart';
import 'package:matrix_chat_app/features/user_preferences/pages/page_1.dart';

class ChatHomePage extends StatefulWidget {
  final Client client;
  const ChatHomePage({
    super.key,
    required this.client,
  });

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  late ProfileInformation profile;
  Future populateUserProfile() async {
    profile = await widget.client.getUserProfile(widget.client.userID!);
  }

  @override
  void initState() {
    super.initState();
    populateUserProfile();
  }

  void joinChat(Room room) async {
    final navigator = Navigator.of(context);
    if (room.membership != Membership.join) {
      await room.join();
    }
    navigator.push(MaterialPageRoute(builder: (context) {
      return Convo(client: widget.client, room: room);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            title: Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Text('MatChat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return Settings(
                              client: widget.client,
                              profile: profile,
                            );
                          }));
                        },
                        icon: Icon(
                          Icons.person_2_rounded,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
            )),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return GenerateScreen();
                }));
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                color: Colors.black,
              )),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: StreamBuilder(
              stream: widget.client.onSync.stream,
              builder: (context, snapshot) {
                return ListView.builder(
                    itemCount: widget.client.rooms.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: InkWell(
                          onTap: () {
                            joinChat(widget.client.rooms[index]);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: null,
                                    radius: 25,
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          widget.client.rooms[index]
                                              .getLocalizedDisplayname(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(height: 5),
                                      Text(
                                          widget.client.rooms[index].lastEvent
                                                  ?.body ??
                                              '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[300],
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                              widget.client.rooms[index].notificationCount != 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.amberAccent,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(widget.client.rooms[index]
                                            .notificationCount
                                            .toString()),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    });
              }),
        ));
  }
}

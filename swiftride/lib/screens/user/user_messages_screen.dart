// lib/screens/user/user_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/utils/constants.dart' show kNavy, kNavy2, kGold, kSurf, kSurf2, kText, kTextS, kSuccess, AppColors;
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/services/auth_service.dart';
import 'user_car_detail_screen.dart' show CompanyChatScreen;

class UserMessagesScreen extends StatefulWidget {
  const UserMessagesScreen({super.key});
  @override State<UserMessagesScreen> createState() => _UserMessagesScreenState();
}

class _UserMessagesScreenState extends State<UserMessagesScreen> {
  final _store = AppDataStore.instance;

  @override
  Widget build(BuildContext context) {
    final companies = _store.chatCompanies;

    return Scaffold(
      backgroundColor: kNavy,
      appBar: AppBar(
        backgroundColor: kNavy2,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: kText.withOpacity(0.7), size: 22),
          ),
        ],
      ),
      body: companies.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.chat_bubble_outline, size: 56, color: kTextS),
              const SizedBox(height: 14),
              const Text('No messages yet', style: TextStyle(color: kTextS, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Chat with companies from a car detail page', style: TextStyle(color: kTextS, fontSize: 13)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: companies.length,
              separatorBuilder: (_, __) => Divider(color: kSurf2, height: 1, indent: 78),
              itemBuilder: (_, i) {
                final companyName = companies[i];
                final msgs = _store.chatWith(companyName);
                final lastMsg = msgs.isNotEmpty ? msgs.last : null;
                final unread = msgs.where((m) => !m.isFromUser).length;

                final colors = [
                  const Color(0xFF1D9E75), const Color(0xFF3B5FD4),
                  const Color(0xFF7F77DD), const Color(0xFFD85A30), const Color(0xFFD4A017),
                ];
                final avatarColor = colors[companyName.length % colors.length];
                final initials = companyName.split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Stack(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: avatarColor.withOpacity(0.18),
                      child: Text(initials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: avatarColor)),
                    ),
                    Positioned(right: 0, bottom: 0,
                      child: Container(
                        width: 11, height: 11,
                        decoration: BoxDecoration(color: kSuccess, shape: BoxShape.circle, border: Border.all(color: kNavy, width: 1.5)),
                      )),
                  ]),
                  title: Row(children: [
                    Expanded(child: Text(companyName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText))),
                    if (lastMsg != null)
                      Text(lastMsg.timeAgo, style: const TextStyle(fontSize: 11, color: kTextS)),
                  ]),
                  subtitle: Row(children: [
                    Expanded(
                      child: Text(
                        lastMsg?.text ?? '',
                        style: TextStyle(fontSize: 12, color: unread > 0 ? kText : kTextS,
                            fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                        child: Center(child: Text('$unread',
                            style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w800))),
                      ),
                    ],
                  ]),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CompanyChatScreen(
                      companyName: companyName,
                      initials: initials,
                      avatarColor: avatarColor,
                    ),
                  )).then((_) => setState(() {})),
                );
              },
            ),
    );
  }
}

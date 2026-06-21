import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static final List<_ChatItem> _chats = [
    _ChatItem(company: 'DriveKigali', avatar: 'DK', lastMsg: 'Your car is ready for pickup at 10 AM.', time: '10:32 AM', unread: 2, avatarColor: Color(0xFF1D9E75)),
    _ChatItem(company: 'SafariWheels', avatar: 'SW', lastMsg: 'Thank you for your booking!', time: 'Yesterday', unread: 0, avatarColor: Color(0xFF3B5FD4)),
    _ChatItem(company: 'LuxDrive', avatar: 'LD', lastMsg: 'Please upload your license before pickup.', time: 'Mon', unread: 1, avatarColor: Color(0xFF7F77DD)),
    _ChatItem(company: 'RwandaRide', avatar: 'RR', lastMsg: 'Your booking has been confirmed.', time: 'Sun', unread: 0, avatarColor: Color(0xFFD85A30)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBg    : AppColors.lightBg;
    final card   = isDark ? AppColors.darkCard  : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder: const Color(0xFFDDE1EE);
    final textPri= isDark ? Colors.white        : const Color(0xFF0A0E1A);
    final textSec= isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 3),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu, size: 22), onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: textPri, size: 22),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _chats.length,
        separatorBuilder: (_, __) => Divider(color: border, height: 1),
        itemBuilder: (_, i) {
          final c = _chats[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            leading: Stack(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: c.avatarColor.withOpacity(0.18),
                child: Text(c.avatar, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.avatarColor)),
              ),
              // Online indicator
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75),
                    shape: BoxShape.circle,
                    border: Border.all(color: card, width: 1.5),
                  ),
                ),
              ),
            ]),
            title: Row(children: [
              Expanded(child: Text(c.company, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri))),
              Text(c.time, style: TextStyle(fontSize: 11, color: textSec)),
            ]),
            subtitle: Row(children: [
              Expanded(
                child: Text(c.lastMsg,
                    style: TextStyle(fontSize: 12, color: c.unread > 0 ? textPri : textSec,
                        fontWeight: c.unread > 0 ? FontWeight.w500 : FontWeight.w400),
                    overflow: TextOverflow.ellipsis),
              ),
              if (c.unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: Center(child: Text('${c.unread}',
                      style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w700))),
                ),
              ],
            ]),
            onTap: () => _openChat(context, c, isDark, card, border, textPri, textSec),
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, _ChatItem c, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    Navigator.push(context, MaterialPageRoute(builder: (_) =>
        _ChatDetailScreen(chat: c, isDark: isDark)));
  }
}

class _ChatItem {
  final String company, avatar, lastMsg, time;
  final int unread;
  final Color avatarColor;
  const _ChatItem({required this.company, required this.avatar, required this.lastMsg, required this.time, required this.unread, required this.avatarColor});
}

// ── Chat detail screen ──────────────────────────────────────────────────────
class _ChatDetailScreen extends StatefulWidget {
  final _ChatItem chat;
  final bool isDark;
  const _ChatDetailScreen({required this.chat, required this.isDark});
  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    _Msg(text: 'Hello! Your booking has been confirmed.', isMe: false),
    _Msg(text: 'Great, thank you! What time can I pick up?', isMe: true),
    _Msg(text: 'Your car is ready for pickup at 10 AM.', isMe: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg     = isDark ? AppColors.darkBg    : AppColors.lightBg;
    final card   = isDark ? AppColors.darkCard  : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder: const Color(0xFFDDE1EE);
    final textPri= isDark ? Colors.white        : const Color(0xFF0A0E1A);
    final textSec= isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPri),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: widget.chat.avatarColor.withOpacity(0.18),
            child: Text(widget.chat.avatar, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.chat.avatarColor)),
          ),
          const SizedBox(width: 10),
          Text(widget.chat.company, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPri)),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final m = _messages[i];
              return Align(
                alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: m.isMe ? AppColors.gold : card,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(m.isMe ? 14 : 4),
                      bottomRight: Radius.circular(m.isMe ? 4 : 14),
                    ),
                    border: m.isMe ? null : Border.all(color: border, width: 0.5),
                  ),
                  child: Text(m.text, style: TextStyle(
                      fontSize: 13,
                      color: m.isMe ? Colors.black : textPri)),
                ),
              );
            },
          ),
        ),
        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: card,
            border: Border(top: BorderSide(color: border, width: 0.5)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(color: textPri, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(color: textSec, fontSize: 13),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (_controller.text.trim().isEmpty) return;
                setState(() {
                  _messages.add(_Msg(text: _controller.text.trim(), isMe: true));
                  _controller.clear();
                });
              },
              child: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.black, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  const _Msg({required this.text, required this.isMe});
}

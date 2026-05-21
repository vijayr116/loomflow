import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:loomflow/core/common/loading_screen.dart';
import 'package:loomflow/features/chat/bloc/chat_bloc.dart';
import 'package:loomflow/features/chat/bloc/chat_event.dart';
import 'package:loomflow/features/chat/bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String weaverName;
  const ChatScreen({super.key, required this.chatId, required this.weaverName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // context.read<ChatBloc>().add(LoadMessageEvent(widget.chatId));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weaverName),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<ChatBloc>().add(DeleteAllMessagesEvent());
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),

      body: Column(
        children: [
          ///  Messages List
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.status == ChatStatus.loading) {
                  return const Center(child: LoomLoadingWidget());
                }

                if (state.messages.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isMe = msg.senderId == currentUser?.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ✉️ Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;

                    context.read<ChatBloc>().add(
                      SendMessageEvent(
                        chatId: widget.chatId,
                        text: _controller.text.trim(),
                      ),
                    );

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:loomflow/features/chat/bloc/chat_bloc.dart';
// import 'package:loomflow/features/chat/bloc/chat_event.dart';
// // import 'package:ping_me/features/chat/bloc/chat_bloc.dart';
// // import 'package:ping_me/features/chat/bloc/chat_event.dart';
// // import 'package:ping_me/features/chat/bloc/chat_state.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:loomflow/features/chat/bloc/chat_state.dart';

// // ─────────────────────────────────────────────────────────────
// //  Design Tokens
// // ─────────────────────────────────────────────────────────────
// class _ChatTheme {
//   // Background layers
//   static const Color scaffold = Color(0xFF0D0F14);
//   static const Color surface = Color(0xFF161820);
//   static const Color surfaceMid = Color(0xFF1E2029);
//   static const Color inputBg = Color(0xFF23262F);

//   // Bubble colours
//   static const Color bubbleMe = Color(0xFF4F6EF7);
//   static const Color bubbleThem = Color(0xFF23262F);

//   // Text
//   static const Color textPrimary = Color(0xFFEEEFF5);
//   static const Color textSecondary = Color(0xFF8B8FA8);
//   static const Color textMe = Color(0xFFFFFFFF);
//   static const Color textThem = Color(0xFFD5D7E4);

//   // Accent / online dot
//   static const Color accent = Color(0xFF4F6EF7);
//   static const Color online = Color(0xFF3DD68C);

//   // Divider / border
//   static const Color border = Color(0xFF2A2D3A);

//   static const TextStyle displayFont = TextStyle(
//     fontFamily: 'SF Pro Display', // falls back to default sans-serif
//     fontFamilyFallback: ['Helvetica Neue', 'Arial'],
//   );
// }

// // ─────────────────────────────────────────────────────────────
// //  ChatScreen
// // ─────────────────────────────────────────────────────────────
// class ChatScreen extends StatefulWidget {
//   final String chatId;
//   const ChatScreen({super.key, required this.chatId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scroll = ScrollController();
//   final FocusNode _focusNode = FocusNode();

//   bool _hasText = false;

//   // Per-message entrance animation map
//   final Map<int, AnimationController> _msgControllers = {};

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() {
//       final has = _controller.text.trim().isNotEmpty;
//       if (has != _hasText) setState(() => _hasText = has);
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scroll.dispose();
//     _focusNode.dispose();
//     for (final c in _msgControllers.values) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   AnimationController _controllerFor(int index) {
//     return _msgControllers.putIfAbsent(index, () {
//       final c = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 320),
//       )..forward();
//       return c;
//     });
//   }

//   void _sendMessage() {
//     if (_controller.text.trim().isEmpty) return;
//     HapticFeedback.lightImpact();
//     context.read<ChatBloc>().add(
//       SendMessageEvent(chatId: widget.chatId, text: _controller.text.trim()),
//     );
//     _controller.clear();
//   }

//   // ───────────────────── BUILD ─────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Theme(
//       data: ThemeData.dark(),
//       child: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle.light,
//         child: Scaffold(
//           backgroundColor: _ChatTheme.scaffold,
//           appBar: _buildAppBar(currentUser),
//           body: Column(
//             children: [
//               Expanded(child: _buildMessageList(currentUser)),
//               _buildInputBar(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────── APP BAR ───────────────────
//   PreferredSizeWidget _buildAppBar(User? user) {
//     final initial = (user?.email ?? '?').substring(0, 1).toUpperCase();
//     final email = user?.email ?? 'Unknown';

//     return PreferredSize(
//       preferredSize: const Size.fromHeight(68),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _ChatTheme.surface,
//           border: Border(
//             bottom: BorderSide(color: _ChatTheme.border, width: 1),
//           ),
//         ),
//         child: SafeArea(
//           bottom: false,
//           child: SizedBox(
//             height: 68,
//             child: Row(
//               children: [
//                 // Back button
//                 const SizedBox(width: 4),
//                 IconButton(
//                   icon: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: _ChatTheme.textPrimary,
//                     size: 20,
//                   ),
//                   onPressed: () => Navigator.maybePop(context),
//                 ),

//                 // Avatar
//                 _Avatar(initial: initial, size: 40),
//                 const SizedBox(width: 12),

//                 // Name + status
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         email,
//                         style: _ChatTheme.displayFont.copyWith(
//                           color: _ChatTheme.textPrimary,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: -0.2,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Container(
//                             width: 7,
//                             height: 7,
//                             decoration: const BoxDecoration(
//                               color: _ChatTheme.online,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             'Online',
//                             style: _ChatTheme.displayFont.copyWith(
//                               color: _ChatTheme.online,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Actions
//                 IconButton(
//                   icon: const Icon(
//                     Icons.videocam_outlined,
//                     color: _ChatTheme.textSecondary,
//                     size: 22,
//                   ),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: const Icon(
//                     Icons.call_outlined,
//                     color: _ChatTheme.textSecondary,
//                     size: 20,
//                   ),
//                   onPressed: () {},
//                 ),
//                 PopupMenuButton<String>(
//                   icon: const Icon(
//                     Icons.more_vert,
//                     color: _ChatTheme.textSecondary,
//                     size: 22,
//                   ),
//                   color: _ChatTheme.surfaceMid,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     side: const BorderSide(color: _ChatTheme.border),
//                   ),
//                   itemBuilder: (_) => [
//                     PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.delete_outline,
//                             color: Color(0xFFEF5350),
//                             size: 18,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             'Clear chat',
//                             style: _ChatTheme.displayFont.copyWith(
//                               color: const Color(0xFFEF5350),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   onSelected: (v) {
//                     if (v == 'delete') {
//                       context.read<ChatBloc>().add(DeleteAllMessagesEvent());
//                     }
//                   },
//                 ),
//                 const SizedBox(width: 4),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ──────────────── MESSAGE LIST ────────────────
//   Widget _buildMessageList(User? user) {
//     return BlocBuilder<ChatBloc, ChatState>(
//       builder: (context, state) {
//         if (state.status == ChatStatus.loading) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: _ChatTheme.accent,
//               strokeWidth: 2,
//             ),
//           );
//         }

//         if (state.messages.isEmpty) {
//           return _EmptyState();
//         }

//         return ListView.builder(
//           controller: _scroll,
//           reverse: true,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           itemCount: state.messages.length,
//           itemBuilder: (context, index) {
//             final msg = state.messages[index];
//             final isMe = msg.senderId == user?.uid;

//             // Determine if we should show a date separator
//             // (simplified – shows for every 10th item as an example;
//             //  replace with real date-diff logic against msg.timestamp)
//             final showDate = index == state.messages.length - 1;

//             final anim = _controllerFor(index);

//             return Column(
//               children: [
//                 if (showDate) _DateChip(label: 'Today'),
//                 SlideTransition(
//                   position:
//                       Tween<Offset>(
//                         begin: Offset(isMe ? 0.15 : -0.15, 0),
//                         end: Offset.zero,
//                       ).animate(
//                         CurvedAnimation(
//                           parent: anim,
//                           curve: Curves.easeOutCubic,
//                         ),
//                       ),
//                   child: FadeTransition(
//                     opacity: anim,
//                     child: _MessageBubble(
//                       text: msg.text,
//                       isMe: isMe,
//                       // pass msg.timestamp here if available
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // ──────────────── INPUT BAR ────────────────
//   Widget _buildInputBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: _ChatTheme.surface,
//         border: Border(top: BorderSide(color: _ChatTheme.border, width: 1)),
//       ),
//       padding: EdgeInsets.only(
//         left: 12,
//         right: 12,
//         top: 10,
//         bottom: MediaQuery.of(context).padding.bottom + 10,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // Attachment button
//           _CircleAction(icon: Icons.add, onTap: () {}),
//           const SizedBox(width: 8),

//           // Text field
//           Expanded(
//             child: Container(
//               constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
//               decoration: BoxDecoration(
//                 color: _ChatTheme.inputBg,
//                 borderRadius: BorderRadius.circular(22),
//                 border: Border.all(color: _ChatTheme.border, width: 1),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       focusNode: _focusNode,
//                       minLines: 1,
//                       maxLines: 5,
//                       textInputAction: TextInputAction.newline,
//                       keyboardType: TextInputType.multiline,
//                       style: _ChatTheme.displayFont.copyWith(
//                         color: _ChatTheme.textPrimary,
//                         fontSize: 15,
//                         height: 1.45,
//                       ),
//                       cursorColor: _ChatTheme.accent,
//                       decoration: InputDecoration(
//                         hintText: 'Message…',
//                         hintStyle: _ChatTheme.displayFont.copyWith(
//                           color: _ChatTheme.textSecondary,
//                           fontSize: 15,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 11,
//                         ),
//                         border: InputBorder.none,
//                         enabledBorder: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   // Emoji button inside field
//                   Padding(
//                     padding: const EdgeInsets.only(right: 6, bottom: 6),
//                     child: IconButton(
//                       constraints: const BoxConstraints(
//                         minWidth: 32,
//                         minHeight: 32,
//                       ),
//                       padding: EdgeInsets.zero,
//                       icon: const Icon(
//                         Icons.emoji_emotions_outlined,
//                         color: _ChatTheme.textSecondary,
//                         size: 20,
//                       ),
//                       onPressed: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),

//           // Send / Mic button
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 220),
//             transitionBuilder: (child, anim) =>
//                 ScaleTransition(scale: anim, child: child),
//             child: _hasText
//                 ? _SendButton(key: const ValueKey('send'), onTap: _sendMessage)
//                 : _CircleAction(
//                     key: const ValueKey('mic'),
//                     icon: Icons.mic_none_rounded,
//                     onTap: () {},
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Message Bubble
// // ─────────────────────────────────────────────────────────────
// class _MessageBubble extends StatelessWidget {
//   final String text;
//   final bool isMe;
//   final String? time;

//   const _MessageBubble({required this.text, required this.isMe, this.time});

//   @override
//   Widget build(BuildContext context) {
//     const radius = Radius.circular(18);
//     const tightRadius = Radius.circular(5);

//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.72,
//         ),
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 3),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: isMe ? _ChatTheme.bubbleMe : _ChatTheme.bubbleThem,
//             borderRadius: BorderRadius.only(
//               topLeft: radius,
//               topRight: radius,
//               bottomLeft: isMe ? radius : tightRadius,
//               bottomRight: isMe ? tightRadius : radius,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.18),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: isMe
//                 ? CrossAxisAlignment.end
//                 : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 text,
//                 style: _ChatTheme.displayFont.copyWith(
//                   color: isMe ? _ChatTheme.textMe : _ChatTheme.textThem,
//                   fontSize: 15,
//                   height: 1.45,
//                 ),
//               ),
//               if (time != null) ...[
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       time!,
//                       style: _ChatTheme.displayFont.copyWith(
//                         color: isMe
//                             ? Colors.white.withOpacity(0.55)
//                             : _ChatTheme.textSecondary,
//                         fontSize: 11,
//                       ),
//                     ),
//                     if (isMe) ...[
//                       const SizedBox(width: 4),
//                       Icon(
//                         Icons.done_all_rounded,
//                         size: 14,
//                         color: Colors.white.withOpacity(0.65),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Avatar
// // ─────────────────────────────────────────────────────────────
// class _Avatar extends StatelessWidget {
//   final String initial;
//   final double size;
//   const _Avatar({required this.initial, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6B8AF7), Color(0xFF4F6EF7)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         shape: BoxShape.circle,
//         border: Border.all(color: _ChatTheme.border, width: 2),
//       ),
//       child: Center(
//         child: Text(
//           initial,
//           style: _ChatTheme.displayFont.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: size * 0.40,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Send Button
// // ─────────────────────────────────────────────────────────────
// class _SendButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _SendButton({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF6B8AF7), Color(0xFF3F5BE8)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF4F6EF7).withOpacity(0.45),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Circle Action (mic / attach)
// // ─────────────────────────────────────────────────────────────
// class _CircleAction extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _CircleAction({super.key, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: _ChatTheme.inputBg,
//           shape: BoxShape.circle,
//           border: Border.all(color: _ChatTheme.border, width: 1),
//         ),
//         child: Icon(icon, color: _ChatTheme.textSecondary, size: 22),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Date Chip
// // ─────────────────────────────────────────────────────────────
// class _DateChip extends StatelessWidget {
//   final String label;
//   const _DateChip({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 14),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//         decoration: BoxDecoration(
//           color: _ChatTheme.surfaceMid,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: _ChatTheme.border, width: 1),
//         ),
//         child: Text(
//           label,
//           style: _ChatTheme.displayFont.copyWith(
//             color: _ChatTheme.textSecondary,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Empty State
// // ─────────────────────────────────────────────────────────────
// class _EmptyState extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               color: _ChatTheme.surfaceMid,
//               shape: BoxShape.circle,
//               border: Border.all(color: _ChatTheme.border, width: 1.5),
//             ),
//             child: const Icon(
//               Icons.chat_bubble_outline_rounded,
//               color: _ChatTheme.textSecondary,
//               size: 32,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No messages yet',
//             style: _ChatTheme.displayFont.copyWith(
//               color: _ChatTheme.textPrimary,
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Send a message to get the\nconversation started.',
//             textAlign: TextAlign.center,
//             style: _ChatTheme.displayFont.copyWith(
//               color: _ChatTheme.textSecondary,
//               fontSize: 14,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

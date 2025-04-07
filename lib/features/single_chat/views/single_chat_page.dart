import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/common/collapsed_header.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/message_felicitup/widgets/chat_space.dart';
import 'package:felicitup_app/features/single_chat/bloc/single_chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SingleChatPage extends StatefulWidget {
  const SingleChatPage({
    super.key,
    required this.data,
  });

  final SingleChatModel data;

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> with WidgetsBindingObserver {
  final TextEditingController textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final currentChatId = context.read<SingleChatBloc>().state.currentChatId;
    if (currentChatId.isNotEmpty) {
      context.read<SingleChatBloc>().add(SingleChatEvent.startListening(currentChatId));
    } else {
      context.read<SingleChatBloc>().add(SingleChatEvent.setCurrentChatId(widget.data.chatId ?? ''));
      context.read<SingleChatBloc>().add(SingleChatEvent.startListening(widget.data.chatId ?? ''));
    }
  }

  @override
  void dispose() {
    textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // deleteId();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.go(RouterPaths.listSingleChat);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                CollapsedHeader(
                  title: 'Chat con ${widget.data.userName}',
                  onPressed: () async => context.go(RouterPaths.listSingleChat),
                ),
                SizedBox(height: context.sp(12)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sp(16),
                      vertical: context.sp(8),
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        BlocBuilder<SingleChatBloc, SingleChatState>(
                          builder: (_, state) {
                            List<ChatMessageModel> chatMessages = state.messages;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });

                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, index) {
                                  return chatMessages.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No hay mensajes',
                                            style: context.styles.paragraph,
                                          ),
                                        )
                                      : ChatSpace(
                                          key: ValueKey(chatMessages[index].id),
                                          isMine: chatMessages[index].sendedBy == currentUser?.id,
                                          date: chatMessages[index].sendedAt,
                                          textContent: chatMessages[index].message,
                                          id: chatMessages[index].sendedBy,
                                          name: chatMessages[index].userName,
                                          userImg: chatMessages[index].userImg,
                                        );
                                },
                                childCount: chatMessages.length,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.sp(8)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(16),
                    vertical: context.sp(8),
                  ),
                  child: TextFormField(
                    controller: textController,
                    style: context.styles.paragraph,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    decoration: InputDecoration(
                      fillColor: context.colors.lightGrey,
                      filled: true,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final textValue = textController.text;
                          if (textValue.isNotEmpty) {
                            final ChatMessageModel chatMessage = ChatMessageModel(
                              id: '${widget.data.chatId}-${currentUser?.id}',
                              message: textValue,
                              sendedBy: currentUser?.id ?? '',
                              userName: currentUser?.firstName ?? '',
                              sendedAt: DateTime.now(),
                              userImg: currentUser?.userImg,
                            );
                            context.read<SingleChatBloc>().add(
                                  SingleChatEvent.sendMessage(
                                    chatMessage: chatMessage,
                                    chatId: widget.data.chatId ?? '',
                                    userId: widget.data.friendId ?? '',
                                    userName: widget.data.userName ?? '',
                                    userImage: widget.data.userImage ?? '',
                                  ),
                                );
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });
                            textController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No puedes enviar mensajes vacíos',
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: context.colors.primary,
                        ),
                      ),
                      hintText: 'Escribe un mensaje',
                      hintStyle: context.styles.paragraph.copyWith(
                        color: context.colors.darkGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.sp(20)),
                        borderSide: BorderSide(
                          width: context.sp(1),
                          color: context.colors.darkGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.sp(20)),
                        borderSide: BorderSide(
                          width: context.sp(1),
                          color: context.colors.darkGrey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.sp(20)),
                        borderSide: BorderSide(
                          width: context.sp(1),
                          color: context.colors.darkGrey,
                        ),
                      ),
                    ),
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

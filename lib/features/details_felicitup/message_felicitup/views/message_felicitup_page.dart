import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:felicitup_app/features/details_felicitup/message_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/models.dart';

class MessageFelicitupPage extends StatefulWidget {
  const MessageFelicitupPage({super.key, this.chatId});

  final String? chatId;

  @override
  State<MessageFelicitupPage> createState() => _MessageFelicitupPageState();
}

class _MessageFelicitupPageState extends State<MessageFelicitupPage>
    with WidgetsBindingObserver {
  final TextEditingController textController = TextEditingController();
  final scrollController = ScrollController();

  void deleteId() {
    if (context.mounted) {
      context.read<MessageFelicitupBloc>().add(
        MessageFelicitupEvent.asignCurrentChat(''),
      );
    }
  }

  void assignid() {
    if (context.mounted) {
      final felicitup =
          context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
      context.read<MessageFelicitupBloc>().add(
        MessageFelicitupEvent.asignCurrentChat(felicitup?.chatId ?? ''),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        deleteId();
        break;
      case AppLifecycleState.resumed:
        assignid();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    detailsFelicitupNavigatorKey.currentContext!
        .read<DetailsFelicitupDashboardBloc>()
        .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(1));
    WidgetsBinding.instance.addObserver(this);
    assignid();
    final felicitup =
        context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
    final currentChatId =
        context.read<MessageFelicitupBloc>().state.currentChatId;
    if (currentChatId.isNotEmpty) {
      context.read<MessageFelicitupBloc>().add(
        MessageFelicitupEvent.startListening(currentChatId),
      );
    } else if (widget.chatId != null && widget.chatId != currentChatId) {
      context.read<MessageFelicitupBloc>().add(
        MessageFelicitupEvent.setCurrentChatId(widget.chatId ?? ''),
      );
      context.read<MessageFelicitupBloc>().add(
        MessageFelicitupEvent.startListening(widget.chatId ?? ''),
      );
    } else {
      context.read<MessageFelicitupBloc>().add(
        MessageFelicitupEvent.startListening(felicitup?.chatId ?? ''),
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    deleteId();
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
    return BlocBuilder<
      DetailsFelicitupDashboardBloc,
      DetailsFelicitupDashboardState
    >(
      buildWhen: (previous, current) => previous.felicitup != current.felicitup,
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              deleteId();
              context.go(RouterPaths.felicitupsDashboard);
            }
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: context.colors.background,
              body: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      // reverse: true,
                      slivers: [
                        BlocBuilder<
                          MessageFelicitupBloc,
                          MessageFelicitupState
                        >(
                          builder: (_, state) {
                            List<ChatMessageModel> chatMessages =
                                state.messages;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });

                            return SliverList(
                              delegate: SliverChildBuilderDelegate((_, index) {
                                return ChatSpace(
                                  key: ValueKey(chatMessages[index].id),
                                  isMine:
                                      chatMessages[index].sendedBy ==
                                      currentUser?.id,
                                  date: chatMessages[index].sendedAt,
                                  textContent: chatMessages[index].message,
                                  id: chatMessages[index].sendedBy,
                                  name: chatMessages[index].userName,
                                  userImg: chatMessages[index].userImg,
                                );
                              }, childCount: chatMessages.length),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.sp(8)),
                  TextFormField(
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
                            context.read<MessageFelicitupBloc>().add(
                              MessageFelicitupEvent.sendMessage(
                                ChatMessageModel(
                                  id: '${felicitup?.id}-${currentUser?.id}',
                                  message: textValue,
                                  sendedBy: currentUser?.id ?? '',
                                  userName: currentUser?.firstName ?? '',
                                  sendedAt: DateTime.now(),
                                  userImg: currentUser?.userImg,
                                ),
                                felicitup!,
                                currentUser?.id ?? '',
                                currentUser?.firstName ?? '',
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
                        icon: Icon(Icons.send, color: context.colors.primary),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/message_felicitup/widgets/chat_space.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPastFelicitupPage extends StatefulWidget {
  const ChatPastFelicitupPage({super.key});

  @override
  State<ChatPastFelicitupPage> createState() => _ChatPastFelicitupPageState();
}

class _ChatPastFelicitupPageState extends State<ChatPastFelicitupPage> with WidgetsBindingObserver {
  final TextEditingController textController = TextEditingController();
  final scrollController = ScrollController();

  void deleteId() {
    if (context.mounted) {
      context.read<ChatPastFelicitupBloc>().add(ChatPastFelicitupEvent.asignCurrentChat(''));
    }
  }

  void assignid() {
    if (context.mounted) {
      final felicitup = context.read<DetailsPastFelicitupDashboardBloc>().state.felicitup;
      logger.debug('Assigning chat id: ${felicitup?.chatId}');
      context.read<ChatPastFelicitupBloc>().add(ChatPastFelicitupEvent.asignCurrentChat(felicitup?.chatId ?? ''));
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
        logger.debug('App is paused');
        break;
      case AppLifecycleState.resumed:
        assignid();
        logger.debug('App is resumed');
        break;
      case AppLifecycleState.detached:
        logger.debug('App is suspending');
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    assignid();
    final felicitup = context.read<DetailsPastFelicitupDashboardBloc>().state.felicitup;
    context.read<ChatPastFelicitupBloc>().add(ChatPastFelicitupEvent.startListening(felicitup?.chatId ?? ''));
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
      // Verifica si el controlador está adjunto.
      //Con esto le decimos que la animacion sea hasta el final
      scrollController.animateTo(
        scrollController.position.maxScrollExtent, // El final de la lista.
        duration: Duration(milliseconds: 300), // Duración de la animación.
        curve: Curves.easeOut, // Curva de animación.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsPastFelicitupDashboardBloc, DetailsPastFelicitupDashboardState>(
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      BlocBuilder<ChatPastFelicitupBloc, ChatPastFelicitupState>(
                        builder: (_, state) {
                          List<ChatMessageModel> chatMessages = [...state.messages];
                          final ownerIds = felicitup?.owner.map((owner) => owner.id).toList() ?? [];
                          chatMessages.removeWhere((element) {
                            if (ownerIds.contains(currentUser?.id)) {
                              return element.sendedAt.isBefore(felicitup?.date ?? DateTime.now());
                            } else {
                              return false;
                            }
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });

                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, index) {
                                return ChatSpace(
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
                          context.read<ChatPastFelicitupBloc>().add(
                                ChatPastFelicitupEvent.sendMessage(
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
              ],
            ),
          ),
        );
      },
    );
  }
}

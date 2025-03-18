import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/past_felicitup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PastSection extends StatelessWidget {
  const PastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      builder: (_, state) {
        final listFelicitupsPast = state.listFelicitupsPast;

        return listFelicitupsPast.isEmpty
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(context.sp(20)),
                  margin: EdgeInsets.symmetric(
                    horizontal: context.sp(20),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.sp(30)),
                  ),
                  child: Text(
                    'No estás participando en ninguna felicitup',
                    textAlign: TextAlign.center,
                    style: context.styles.paragraph,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ...List.generate(
                      listFelicitupsPast.length,
                      (index) => GestureDetector(
                        onTap: () {},
                        onLongPress: () {},
                        child: PastFelicitupWidget(
                          felicitup: listFelicitupsPast[index],
                          date: listFelicitupsPast[index].date,
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

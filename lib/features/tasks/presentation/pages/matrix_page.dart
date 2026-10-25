import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/layout.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/matrix_board.dart';

class MatrixPage extends StatelessWidget {
  const MatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                final pending = state.tasks
                    .where((task) => !task.isCompleted)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: PageHeader(
                        overline: 'Eisenhower · ${pending.length} pendientes',
                        title: 'Matriz',
                        subtitle: pending.isEmpty
                            ? 'Crea una tarea y colócala en su cuadrante.'
                            : 'Mantén presionada una tarea para moverla.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: MatrixBoard(tasks: pending)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

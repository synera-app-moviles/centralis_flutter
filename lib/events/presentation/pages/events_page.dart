import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import '../bloc/event_bloc.dart';
        import '../bloc/event_event.dart';
        import '../bloc/event_state.dart';
        import '../widgets/event_card.dart';

        class EventsPage extends StatefulWidget {
          const EventsPage({super.key});

          @override
          State<EventsPage> createState() => _EventsPageState();
        }

        class _EventsPageState extends State<EventsPage> {
          String _selectedFilter = 'My Events';

          @override
          void initState() {
            super.initState();
            _loadEvents();
          }

          void _loadEvents() {
            if (_selectedFilter == 'My Events') {
              // TODO: Obtener userId del token/storage
              context.read<EventBloc>().add(
                const LoadEvents(
                  userId: '00000000-0000-0000-0000-000000000000',
                  filterType: 'creator',
                ),
              );
            } else {
              context.read<EventBloc>().add(const LoadEvents());
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              backgroundColor: const Color(0xFF170F24),
              appBar: AppBar(
                backgroundColor: const Color(0xFF170F24),
                centerTitle: true,
                title: const Text(
                  'Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        _buildFilterChip('My Events'),
                        const SizedBox(width: 8),
                        _buildFilterChip('All Events'),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA68FCC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              final result = await Navigator.pushNamed(context, '/events/create');
                              if (result == true) {
                                _loadEvents(); // Recargar lista después de crear
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF30214A), height: 1),

                  // Lista de eventos con BLoC
                  Expanded(
                    child: BlocBuilder<EventBloc, EventState>(
                      builder: (context, state) {
                        if (state is EventLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is EventError) {
                          return Center(
                            child: Text(
                              state.error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (state is EventsLoaded) {
                          if (state.events.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Color(0xFFA68FCC),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedFilter == 'My Events'
                                        ? 'No tienes eventos creados'
                                        : 'No hay eventos disponibles',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: state.events.length,
                            itemBuilder: (context, index) {
                              final event = state.events[index];
                              return EventCard(
                                event: event,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/events/details',
                                    arguments: event.id,
                                  );
                                },
                                onEdit: _selectedFilter == 'My Events'
                                    ? () async {
                                        final result = await Navigator.pushNamed(
                                          context,
                                          '/events/update',
                                          arguments: event.id,
                                        );
                                        if (result == true) {
                                          _loadEvents();
                                        }
                                      }
                                    : null,
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          Widget _buildFilterChip(String label) {
            final isSelected = _selectedFilter == label;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = label);
                _loadEvents();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFA68FCC) : const Color(0xFF30214A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
        }
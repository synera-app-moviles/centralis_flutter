import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../app/routes/route_names.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../widgets/comments_section.dart';
import '../../data/models/announcement.dart';
import '../../data/models/priority.dart';
import 'edit_announcement_page.dart';

class AnnouncementDetailPage extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailPage({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  bool _isCreator = false;
  AnnouncementBloc? _announcementBloc;
  Announcement? _currentAnnouncement; // Para mantener el estado del anuncio

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeCurrentUser() async {
    // Ya no es necesario almacenar el userId aquí, se maneja en CommentsSection
  }

  Future<void> _checkIfCreator(String announcementCreatorId) async {
    final storageService = sl<SecureStorageService>();
    final currentUserId = await storageService.getUserId();
    
    if (mounted) {
      setState(() {
        _isCreator = currentUserId == announcementCreatorId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _announcementBloc = sl<AnnouncementBloc>()
          ..add(AnnouncementLoadByIdRequested(announcementId: widget.announcementId));
        return _announcementBloc!;
      },
      child: Scaffold(
        backgroundColor: AnnouncementColors.background,
        appBar: _buildAppBar(context),
        body: BlocListener<AnnouncementBloc, AnnouncementState>(
          listener: (context, state) {
            if (state is AnnouncementDetailLoaded) {
              _checkIfCreator(state.announcement.createdBy);
              _currentAnnouncement = state.announcement; // Guardar el anuncio actual
            } else if (state is AnnouncementDeleted) {
              // Redirigir a la lista de anuncios usando named route
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.announcements,
                (route) => false,
              );
            } else if (state is AnnouncementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) {
            // Solo mostrar loading para operaciones que no sean de comentarios
            if (state is AnnouncementLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AnnouncementColors.primary,
                ),
              );
            }

            if (state is AnnouncementError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AnnouncementColors.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _announcementBloc?.add(
                          AnnouncementLoadByIdRequested(announcementId: widget.announcementId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnnouncementColors.primary,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is AnnouncementDetailLoaded) {
              return _buildContent(context, state.announcement);
            }

            // Para estados de comentarios, usar el anuncio guardado
            if ((state is CommentCreated || state is CommentDeleted) && _currentAnnouncement != null) {
              return _buildContent(context, _currentAnnouncement!);
            }

            return const Center(
              child: Text(
                'Announcement not found',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Announcement Detail",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AnnouncementColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isCreator)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _navigateToEdit(context);
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Announcement announcement) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            announcement.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Fecha y prioridad
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(announcement.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  announcement.priority.value.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDetailDate(announcement.createdAt),
                style: const TextStyle(
                  color: AnnouncementColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Imagen si existe
          if (announcement.image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                announcement.image!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AnnouncementColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AnnouncementColors.textSecondary,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Descripción
          Text(
            announcement.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección de comentarios
          CommentsSection(
            announcementId: widget.announcementId,
            comments: announcement.comments,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.normal:
        return Colors.blue;
    }
  }

  String _formatDetailDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  void _navigateToEdit(BuildContext context) async {
    if (_announcementBloc?.state is AnnouncementDetailLoaded) {
      final state = _announcementBloc!.state as AnnouncementDetailLoaded;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditAnnouncementPage(announcement: state.announcement),
        ),
      );
      // La página de edición manejará su propia navegación
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AnnouncementColors.cardBackground,
          title: const Text(
            'Delete Announcement',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this announcement? This action cannot be undone.',
            style: TextStyle(color: AnnouncementColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AnnouncementColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                // Usar la referencia almacenada del bloc
                _announcementBloc?.add(
                  AnnouncementDeleteRequested(announcementId: widget.announcementId),
                );
                Navigator.pop(dialogContext); // Solo cerrar diálogo, el listener maneja la navegación
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
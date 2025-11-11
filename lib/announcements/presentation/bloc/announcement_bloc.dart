import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _announcementRepository;

  AnnouncementBloc({required AnnouncementRepository announcementRepository})
      : _announcementRepository = announcementRepository,
        super(AnnouncementInitial()) {
    on<AnnouncementLoadRequested>(_onLoadRequested);
    on<AnnouncementLoadByIdRequested>(_onLoadByIdRequested);
    on<AnnouncementLoadByPriorityRequested>(_onLoadByPriorityRequested);
    on<AnnouncementLoadByCreatorRequested>(_onLoadByCreatorRequested);
    on<AnnouncementCreateRequested>(_onCreateRequested);
    on<AnnouncementUpdateRequested>(_onUpdateRequested);
    on<AnnouncementDeleteRequested>(_onDeleteRequested);
    on<CommentCreateRequested>(_onCommentCreateRequested);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
    on<CommentsLoadRequested>(_onCommentsLoadRequested);
  }

  Future<void> _onLoadRequested(
    AnnouncementLoadRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await _announcementRepository.getAllAnnouncements();
      emit(AnnouncementLoaded(announcements: announcements));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onLoadByIdRequested(
    AnnouncementLoadByIdRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      // Cargar el anuncio
      final announcement = await _announcementRepository.getAnnouncementById(event.announcementId);
      
      // Cargar los comentarios del anuncio
      final comments = await _announcementRepository.getCommentsByAnnouncement(event.announcementId);
      
      // Crear anuncio con comentarios incluidos
      final announcementWithComments = announcement.copyWith(comments: comments);
      
      emit(AnnouncementDetailLoaded(announcement: announcementWithComments));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onLoadByPriorityRequested(
    AnnouncementLoadByPriorityRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await _announcementRepository.getAnnouncementsByPriority(event.priority);
      emit(AnnouncementLoaded(announcements: announcements));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onLoadByCreatorRequested(
    AnnouncementLoadByCreatorRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await _announcementRepository.getAnnouncementsByCreator(event.creatorId);
      emit(AnnouncementLoaded(announcements: announcements));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AnnouncementCreateRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcement = await _announcementRepository.createAnnouncement(
        title: event.title,
        description: event.description,
        image: event.image,
        priority: event.priority,
        createdBy: event.createdBy,
      );
      emit(AnnouncementCreated(announcement: announcement));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    AnnouncementUpdateRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final announcement = await _announcementRepository.updateAnnouncement(
        announcementId: event.announcementId,
        title: event.title,
        description: event.description,
        image: event.image,
        priority: event.priority,
      );
      emit(AnnouncementUpdated(announcement: announcement));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    AnnouncementDeleteRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      await _announcementRepository.deleteAnnouncement(event.announcementId);
      emit(AnnouncementDeleted(announcementId: event.announcementId));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onCommentCreateRequested(
    CommentCreateRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      final comment = await _announcementRepository.createComment(
        announcementId: event.announcementId,
        employeeId: event.employeeId,
        content: event.content,
      );
      emit(CommentCreated(comment: comment));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _announcementRepository.deleteComment(event.commentId);
      emit(CommentDeleted(commentId: event.commentId));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> _onCommentsLoadRequested(
    CommentsLoadRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    try {
      final comments = await _announcementRepository.getCommentsByAnnouncement(event.announcementId);
      emit(CommentsLoaded(comments: comments, announcementId: event.announcementId));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }
}
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

import '../../../controllers/notification_controller.dart';
import '../../../dto/app/notification/notification_dto.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late NotificationController _notificationController;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _notificationController = NotificationController();
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    await _notificationController.getAllNotifications(context: context);
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<NotificationDTO> _filterNotifications(List<NotificationDTO> notifications) {
    if (_searchQuery.isEmpty) {
      return notifications;
    }
    
    return notifications.where((notification) {
      final title = notification.content.title.toLowerCase();
      final body = notification.content.body.toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return title.contains(query) || body.contains(query);
    }).toList();
  }

  Future<void> _filterByDateRange() async {
    if (_fromDate != null && _toDate != null) {
      await _notificationController.getNotificationsByDateRange(
        fromDate: _fromDate!,
        toDate: _toDate!,
        context: context,
      );
    } else {
      await _loadNotifications();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        // Ajustar las fechas para cubrir todo el día
        _fromDate = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
        _toDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
      await _filterByDateRange();
    }
  }

  void _clearDateRange() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        borderRadius: 16,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildNotificationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.notifications,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Notificaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar notificaciones...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _fromDate != null && _toDate != null
                          ? '${DateFormat('dd/MM/yy').format(_fromDate!)} - ${DateFormat('dd/MM/yy').format(_toDate!)}'
                          : 'Filtrar por fecha de notificacíon',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_fromDate != null && _toDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: _clearDateRange,
            icon: Icon(
              Icons.clear,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
        const SizedBox(width: 8),
        IconButton(
          onPressed: _loadNotifications,
          icon: Icon(
            Icons.refresh,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    return ValueListenableBuilder<bool>(
      valueListenable: _notificationController.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        return ValueListenableBuilder<List<NotificationDTO>>(
          valueListenable: _notificationController.notifications,
          builder: (context, notifications, _) {
            final filteredNotifications = _filterNotifications(notifications);
            
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay notificaciones',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (filteredNotifications.isEmpty && _searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron resultados para "$_searchQuery"',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return _buildNotificationCard(notification);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationDTO notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.content.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                DateFormat('dd/MM/yy HH:mm').format(notification.dateSend),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.content.body,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetdrugegy/Models/Constants.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await Supabase.instance.client
          .from('notifications')
          .select('id, title, message')
          .order('id', ascending: false);

      setState(() {
        notifications = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load notifications';
      });
      print('Error fetching notifications: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appDesign.colorPrimaryDark,
        foregroundColor: appDesign.colorAccent,
        title: Text(
          AppLocalizations.of(context)!.notifications,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        color: appDesign.colorPrimaryDark,
      ));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            ElevatedButton(
              onPressed: _fetchNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: appDesign.colorPrimaryDark,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.9, // 80% of screen height
              child: const Center(
                child: Text(
                  "لا يوجد إشعارات جديدة",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      color: appDesign.colorPrimaryDark,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: appDesign.colorPrimaryLight,
                  width: 1,
                ),
              ),
            ),
            child: ListTile(
              title: Text(notification['title'] ?? ''),
              subtitle: Text(notification['message'] ?? ''),
              leading: const Icon(Icons.notifications),
            ),
          );
        },
      ),
    );
  }
}

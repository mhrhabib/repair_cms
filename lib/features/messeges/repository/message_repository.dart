import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';

/// Repository for message-related API operations
abstract class MessageRepository {
  Future<ConversationModel> getConversation({required String conversationId});
}

class MessageRepositoryImpl implements MessageRepository {
  @override
  Future<ConversationModel> getConversation({required String conversationId}) async {
    try {
      debugPrint('🌐 [MessageRepository] Fetching conversation: $conversationId');

      final Response response = await BaseClient.get(
        url: ApiEndpoints.getConversation.replaceAll('<conversationId>', conversationId),
      );

      debugPrint('📊 [MessageRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle JSON string parsing
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }
        final data = jsonData;

        debugPrint('📦 [MessageRepository] Response data type: ${data.runtimeType}');
        debugPrint('📦 [MessageRepository] Response data keys: ${data is Map ? (data as Map).keys.toList() : "N/A"}');
        if (data is Map && data.containsKey('success')) {
          debugPrint('📦 [MessageRepository] Success value: ${data['success']}');
        }
        if (data is Map && data.containsKey('data')) {
          debugPrint('📦 [MessageRepository] Data field type: ${data['data'].runtimeType}');
          debugPrint('📦 [MessageRepository] Data field value: ${data['data']}');
        }

        // Handle different response structures
        if (data is List) {
          // API returns array of conversation messages directly
          debugPrint('✅ [MessageRepository] Received ${data.length} messages as list, wrapping in model');
          return ConversationModel(
            success: true,
            data: data.map((json) => Conversation.fromJson(json as Map<String, dynamic>)).toList(),
            total: data.length,
            pages: 1,
          );
        } else if (data is Map<String, dynamic>) {
          // Parse the entire response as ConversationModel
          debugPrint('✅ [MessageRepository] Parsing response as ConversationModel');
          final model = ConversationModel.fromJson(data);
          debugPrint('📋 [MessageRepository] Model success: ${model.success}');
          debugPrint('📋 [MessageRepository] Model error: ${model.error}');
          debugPrint('📋 [MessageRepository] Model data type: ${model.data.runtimeType}');
          debugPrint('📋 [MessageRepository] Model data length: ${model.data?.length}');
          if (model.data != null && model.data!.isNotEmpty) {
            debugPrint('📋 [MessageRepository] First item type: ${model.data!.first.runtimeType}');
          }
          return model;
        } else {
          debugPrint('⚠️ [MessageRepository] Unexpected response format');
          return ConversationModel(success: false, error: 'Unexpected response format');
        }
      } else {
        throw MessageException(message: 'Failed to load conversation', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint('❌ [MessageRepository] DioException: ${e.message}');
      throw MessageException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stacktrace) {
      debugPrint('❌ [MessageRepository] Error: $e');
      debugPrintStack(stackTrace: stacktrace);
      throw MessageException(message: 'Error loading conversation: $e');
    }
  }
}

/// Custom exception for message operations
class MessageException implements Exception {
  final String message;
  final int? statusCode;

  MessageException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

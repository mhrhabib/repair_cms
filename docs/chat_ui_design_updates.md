# Chat Conversation Screen - Figma Design Implementation

## Overview
Updated the chat conversation screen to match the provided Figma design with enhanced UI, quotation cards, and improved message display.

## Changes Implemented

### 1. Data Model Updates (`message_model.dart`)

#### Added QuotationModel
```dart
class QuotationModel {
  final String? service;
  final String? description;
  final int? unit;
  final double? price;
  final double? subtotal;
  final double? vatPercent;
  final double? vatAmount;
  final double? totalAmount;
  final bool? accepted;
  final String? acceptedAt;
  final String? paymentStatus; // "Paid", "Not Paid"
  final DateTime? timestamp;
}
```

#### Updated MessageContent
- Added `quotation` field to support quotation messages
- Quotations are sent with `messageType: 'quotation'`

### 2. Chat Screen UI Updates (`chat_conversation_screen.dart`)

#### App Bar Design
- **Title**: Shows participant name (16px, bold)
- **Subtitle**: "Online" status (12px, gray)
- **Actions**: Circular info button with blue gradient background
- **Clean Design**: Removed extra icons, focused on essential info

#### Empty State
- **Icon**: Large gradient circular container with chat icon
- **Title**: "Empty Inbox" (20px, bold)
- **Description**: "You have no messages in your inbox" (14px, gray)
- **Center Aligned**: Vertical center alignment

#### Message Bubbles

**Standard Messages:**
- **Sent Messages**: Light blue background (`#D6E8FF`)
- **Received Messages**: White background with subtle shadow
- **Sender Name**: Displayed above received messages (12px, bold)
- **Time Display**: "Today HH:MM" format below message
- **Read Receipts**: Blue double-check for read, gray single-check for sent
- **Max Width**: 70% of screen width
- **Border Radius**: 16px rounded corners

**Quotation Cards:**
- **Full Width**: 85% of screen width
- **Background**: Light blue for sent, white for received
- **Header**: "Quotation" label with timestamp
- **Service Table**: 3-column layout (Service, Unit, Price)
- **Service Details**: Service name + description
- **Pricing Breakdown**:
  - Subtotal excl. VAT
  - VAT percentage and amount
  - **Total Amount** (bold, 14px)
- **Status Badges**:
  - ✅ **Quotation Accepted**: Green badge with check icon
  - 💳 **Payment Status**: Green "Paid" or Red "Not Paid" badge
- **Styling**: Clean borders, proper spacing, professional look

#### Message Input Area
- **Plus Button**: Gray circular button on left (add attachments)
- **Input Field**: 
  - Light gray background (`#F5F5F5`)
  - Placeholder: "Write a message..."
  - Rounded corners (24px)
  - Auto-expanding height (max 100px)
  - Attachment icon inside input field
- **Send Button**: 
  - Blue gradient circular button
  - White send icon
  - 40x40px size
- **Layout**: Row with proper spacing between elements

#### Attachment Options Bottom Sheet
- **Design**: Rounded top corners, white background
- **Handle**: Gray drag indicator at top
- **Title**: "Attach Files" (18px, bold)
- **Options**: 3 circular buttons
  - 📷 Gallery (purple)
  - 📸 Camera (blue)
  - 📄 Document (orange)
- **Layout**: Evenly spaced row

## Design Features

### Color Palette
- **Primary Blue**: `#4A90E2`
- **Light Blue**: `#D6E8FF` (sent messages)
- **Darker Blue**: `#357ABD` (gradient end)
- **Text Dark**: `#1E3A5F`
- **Success Green**: `#4CAF50` / `#E8F5E9` (background)
- **Error Red**: `#E53935` / `#FFEBEE` (background)
- **Gray Shades**: Various for text, backgrounds, borders

### Typography
- **Message Text**: 14px
- **Quotation Header**: 15px, semi-bold
- **Total Amount**: 14px, bold
- **Timestamps**: 11px
- **Service Names**: 13px, semi-bold
- **Status Badges**: 10-12px, bold

### Spacing & Dimensions
- **Message Padding**: 16px horizontal, 12px vertical
- **Message Gap**: 16px between messages
- **Quotation Card**: 16px padding all around
- **Border Radius**: 16px for cards, 24px for inputs
- **Avatar Size**: 32px diameter (16px radius)
- **Button Size**: 40x40px for circular buttons

## Usage Examples

### Sending a Quotation Message
```dart
context.read<MessageCubit>().sendMessage(
  conversationId: 'conv_123',
  sender: SenderReceiver(email: 'user@example.com', name: 'User'),
  receiver: SenderReceiver(email: 'client@example.com', name: 'Client'),
  messageText: 'Hi Peter, let me figure out how is go.',
  messageType: 'quotation',
  userId: 'user_123',
  loggedUserId: 'user_123',
  quotation: QuotationModel(
    service: 'Samsung S20 Screen Replacement',
    description: 'Genuine original spare parts',
    unit: 1,
    price: 100.00,
    subtotal: 100.00,
    vatPercent: 20.0,
    vatAmount: 20.00,
    totalAmount: 120.00,
    accepted: true,
    acceptedAt: 'Today, 15:23',
    paymentStatus: 'Paid', // or 'Not Paid'
    timestamp: DateTime.now(),
  ),
);
```

### Displaying Messages
The screen automatically detects message type and displays:
- Standard text messages in simple bubbles
- Quotation messages in detailed cards with pricing
- Internal comments with special badges
- Attachments with file information

## Technical Implementation

### Message Type Detection
```dart
final messageType = message.message?.messageType ?? 'standard';
final hasQuotation = messageType == 'quotation' && message.message?.quotation != null;

if (hasQuotation) {
  return _buildQuotationCard(message.message!.quotation!, isMe);
} else {
  return _buildStandardMessage(...);
}
```

### Time Formatting
- **Full Time**: "HH:MM" format (e.g., "15:22")
- **Date Display**: "Today" for current day messages
- **Read Receipts**: Single check (sent), double check (read)

### Responsive Design
- Messages adapt to screen width (max 70% for text, 85% for quotations)
- Input area respects safe area bottom padding
- Scroll to bottom on new messages
- Auto-expanding text input

## UI/UX Improvements

1. **Cleaner Header**: Simplified app bar with essential info only
2. **Better Message Distinction**: Different backgrounds for sent/received
3. **Professional Quotations**: Detailed pricing cards matching business needs
4. **Status Indicators**: Clear accepted/payment status badges
5. **Improved Input**: Modern, user-friendly message composition area
6. **Attachment Support**: Easy access to multiple attachment types
7. **Visual Hierarchy**: Proper spacing, sizing, and emphasis

## Future Enhancements

1. **File Upload**: Implement actual file picker integration
2. **Image Preview**: Show image thumbnails in quotation cards
3. **Copy Text**: Long-press to copy message text
4. **Quotation Actions**: Accept/reject buttons for pending quotations
5. **Payment Integration**: Direct payment from quotation card
6. **Message Reactions**: Add emoji reactions to messages
7. **Voice Messages**: Record and send audio messages
8. **Read Receipts Real-time**: Live updates when message is read

## Testing Checklist

- [x] Quotation cards display correctly
- [x] Message bubbles have proper colors
- [x] Time formatting works correctly
- [x] Attachment bottom sheet opens
- [x] Send button triggers message send
- [x] App bar displays user info
- [x] Empty state shows when no messages
- [x] Scroll to bottom on new messages
- [x] Read receipts display correctly
- [x] Payment status badges show correct colors
- [ ] File attachment actually uploads files
- [ ] Camera integration works
- [ ] Gallery picker works
- [ ] Document picker works

## Design Match Verification

✅ App bar with user name and online status
✅ Info button with blue circle background
✅ Message bubbles with proper styling
✅ Quotation cards with detailed pricing
✅ Green "Quotation Accepted" badge
✅ Red/Green payment status badges
✅ Time display format (HH:MM)
✅ "Today" date label
✅ Plus button for attachments
✅ Send button with gradient
✅ Input field with gray background
✅ Attachment options bottom sheet
✅ Empty state with gradient icon

The implementation now matches the Figma design specifications!

// import 'package:flutter/material.dart';
// import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
// import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

// class ReceiptScreen extends StatelessWidget {
//   const ReceiptScreen({super.key, required this.job});
//   final SingleJobModel job;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       appBar: AppBar(
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
//         title: const Text('Preview'),
//         actions: [
//           IconButton(icon: const Icon(Icons.cloud_download_outlined), onPressed: () {}),
//           IconButton(
//             icon: const Icon(Icons.print_outlined),
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => PrintSettingsPage(jobData: job)));
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Container(
//             margin: const EdgeInsets.all(16),
//             constraints: const BoxConstraints(maxWidth: 800),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
//               ],
//             ),
//             child: JobReceiptWidget(jobData: job),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class JobReceiptWidget extends StatelessWidget {
//   final SingleJobModel jobData;

//   const JobReceiptWidget({super.key, required this.jobData});

//   @override
//   Widget build(BuildContext context) {
//     final customer = jobData.data!.contact![0];
//     final device = jobData.data!.device!.isNotEmpty ? jobData.data!.device![0] : null;
//     final services = jobData.data!.services;
//     final defect = jobData.data!.defect!.isNotEmpty ? jobData.data!.defect![0] : null;

//     // Format currency values
//     // final formattedSubTotal = _formatCurrency(jobData.subTotal);
//     // final formattedTotal = _formatCurrency(jobData.total);

//     return Padding(
//       padding: const EdgeInsets.all(32.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with logo and company name
//           Align(
//             alignment: Alignment.centerRight,
//             child: const Text(
//               'Sakani',
//               style: TextStyle(
//                 fontSize: 48,
//                 fontWeight: FontWeight.w300,
//                 color: Color(0xFF00A86B),
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Using billing address company name if available, otherwise a default
//                     Text(
//                       customer.billingAddress.street.isNotEmpty
//                           ? '${customer.billingAddress.street} ${customer.billingAddress.num}'
//                           : 'Company Name',
//                       style: const TextStyle(fontSize: 8, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(jobData.assignerName, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
//                     Text(customer.shippingAddress.city, style: const TextStyle(fontSize: 8)),
//                     Text(
//                       '${customer.shippingAddress.zip} ${customer.shippingAddress.street}',
//                       style: const TextStyle(fontSize: 8),
//                     ),
//                     Text(customer.shippingAddress.country, style: const TextStyle(fontSize: 8)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Container(
//               height: 60,
//               width: 100,
//               decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 40,
//                     child: Row(
//                       children: List.generate(20, (index) {
//                         return Expanded(child: Container(color: index % 2 == 0 ? Colors.black : Colors.white));
//                       }),
//                     ),
//                   ),
//                   Text(jobData.jobNo.toString(), style: const TextStyle(fontSize: 8)),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),

//           // Date and Job Info
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _buildInfoRow('Date:', jobData.dueDate != null ? jobData.dueDate.toString() : 'N/A'),
//                   _buildInfoRow('Job No:', jobData.jobNo.toString()),
//                   _buildInfoRow('Customer No:', customer.customerNo),
//                   _buildInfoRow('Agent:', jobData.assignerName ?? 'N/A'),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),

//           // Barcode placeholder

//           // Job Receipt Title
//           const Text('Job Receipt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),

//           // Salutation
//           const Text('Hi there,', style: TextStyle(fontSize: 8)),
//           const Text(
//             'Thank you for your trust. We are committed to processing your order as quickly as possible.',
//             style: TextStyle(fontSize: 8),
//           ),
//           const SizedBox(height: 8),

//           // Device Details - Side by side
//           Container(
//             decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(4),

//                   decoration: BoxDecoration(color: Colors.grey[300]),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Device details:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
//                       Text('Physical location:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
//                       Text('Job type, reference:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
//                       Text('Description:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           device != null
//                               ? '${device.brand} ${device.model ?? ''}, IMEI: ${device.imei ?? 'N/A'}'
//                               : 'Device information not available',
//                           style: TextStyle(fontSize: 8),
//                         ),
//                         Text(jobData.physicalLocation ?? 'Not specified', style: TextStyle(fontSize: 8)),
//                         Text('${jobData.jobType}, ${defect?.reference ?? 'N/A'}', style: TextStyle(fontSize: 8)),
//                         Text(defect?.description ?? 'No description provided', style: TextStyle(fontSize: 8)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),

//           // Service Section - Side by side
//           Container(
//             decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text('Service', style: TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                         SizedBox(
//                           width: 100,
//                           child: Text(
//                             'Price',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.right,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Service items
//                 ...services.map((service) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Row(
//                         children: [
//                           Expanded(child: Text('${service.name} - ${service.description ?? ''}')),
//                           SizedBox(
//                             width: 100,
//                             child: Text(_formatCurrency(service.priceExclVat), textAlign: TextAlign.right),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),

//                 // Subtotal
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                         SizedBox(
//                           width: 100,
//                           child: Text(
//                             formattedSubTotal,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.right,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Total
//                 Container(
//                   decoration: BoxDecoration(color: Colors.grey[100]),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                         SizedBox(
//                           width: 100,
//                           child: Text(
//                             formattedTotal,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.right,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),

//           // Terms and Conditions
//           Text(
//             'Terms of service: If the defect is not covered by the manufacturer\'s warranty, I agree to the following.The execution of a paid repair after the creation of a cost estimate at the price of XXX euros including VAT. (Note: If a repair order is subsequently issued, only the actual repair costs according to the cost estimate will be invoiced). I want to be informed before the execution of a paid repair. If I decide against the execution of a repair or if it is not feasible, a handling or inspection fee of XXX euros including VAT will be charged upon return of the device. Note: The repair service within the framework of the manufacturer\'s device warranty is a voluntary service to our customers. For repairs covered by the manufacturer\'s device warranty, there are no costs for the customer. The inspection of the device in the shop can only be superficial. If, upon closer inspection by a professional, it is found that the defect of the device is not covered by the manufacturer\'s device warranty, the repair is chargeable. This applies in particular to damages due to liquid or moisture ingress, impact damages, and proven self-interference. Any warranty claims remain unaffected. The repaired or replaced device must be picked up within 3 months from the date of submission at any shop where it was received. If not collected, the device becomes the property of the client. The device will be stored for another 3 months, after which it will be disposed of or recycled. We assume no liability for data loss or encryption, data stored in the device may be lost. The client is obligated to use the loaned device with care. If the loaned device is damaged or not returned after the completion of the order, the replacement of the respective loaned device plus a processing fee of EUR 50 plus VAT will be invoiced. The terms and conditions of XXXXX apply.',
//             style: TextStyle(fontSize: 10, color: Colors.grey[700]),
//           ),
//           const SizedBox(height: 24),

//           // QR Code placeholder
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
//             child: const Center(child: Text('QR', style: TextStyle(fontSize: 24))),
//           ),
//           const SizedBox(height: 32),

//           // Footer - Using customer details for company information
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       customer.organization.isNotEmpty ? customer.organization : 'Company Name',
//                       style: TextStyle(fontSize: 8),
//                     ),
//                     Text(
//                       '${customer.billingAddress.street} ${customer.billingAddress.num}',
//                       style: TextStyle(fontSize: 8),
//                     ),
//                     Text(
//                       '${customer.billingAddress.zip} ${customer.billingAddress.city}',
//                       style: TextStyle(fontSize: 8),
//                     ),
//                     Text(customer.billingAddress.country, style: TextStyle(fontSize: 8)),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Contact Information', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
//                     Text('Telephone: ${customer.telephone}', style: TextStyle(fontSize: 8)),
//                     Text('E-Mail: ${customer.email}', style: TextStyle(fontSize: 8)),
//                     // Using the first contact person if available
//                     if (customer.contactPersons != null && customer.contactPersons!.isNotEmpty)
//                       Text(
//                         'Contact: ${customer.contactPersons![0].firstName} ${customer.contactPersons![0].lastName}',
//                         style: TextStyle(fontSize: 8),
//                       ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Bank Information', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
//                     const Text('IBAN: [Bank details]', style: TextStyle(fontSize: 8)),
//                     const Text('BIC: [BIC code]', style: TextStyle(fontSize: 8)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatCurrency(dynamic amount) {
//     if (amount == null) return '€0.00';

//     try {
//       final numericAmount = double.tryParse(amount.toString()) ?? 0.0;
//       return '€${numericAmount.toStringAsFixed(2)}';
//     } catch (e) {
//       return '€0.00';
//     }
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             child: Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
//           ),
//           Text(value, style: TextStyle(fontSize: 8)),
//         ],
//       ),
//     );
//   }
// }

// class PrintSettingsPage extends StatefulWidget {
//   final SingleJobModel jobData;

//   const PrintSettingsPage({super.key, required this.jobData});

//   @override
//   State<PrintSettingsPage> createState() => _PrintSettingsPageState();
// }

// class _PrintSettingsPageState extends State<PrintSettingsPage> {
//   int copies = 1;
//   bool isPortrait = false;
//   String selectedPages = 'All';
//   String selectedColor = 'Color';
//   String selectedPaperSize = 'ISO A4';
//   String selectedPrintType = 'Single-sided';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
//         title: const Text('Preview'),
//         actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
//       ),
//       body: Column(
//         children: [
//           // Preview thumbnail
//           Container(
//             height: 200,
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               width: 140,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Job Receipt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Expanded(
//                           child: Text(
//                             'Job No: ${widget.jobData.data!.iV}\nCustomer: ${widget.jobData.data?.deviceId}\nDevice: ${widget.jobData.data!.device!.isNotEmpty ? widget.jobData.data!.device![0].model ?? 'N/A' : 'N/A'}\nServices: ${widget.jobData.data!.services!.map((s) => s.name).join(', ')}\n\nThis is a preview of the job receipt. The actual printout may vary based on printer settings and configurations.',
//                             style: TextStyle(fontSize: 6, color: Colors.grey[700]),
//                             maxLines: 10,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 8,
//                     right: 8,
//                     child: Container(
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
//                       child: const Icon(Icons.check, color: Colors.white, size: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Settings
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 _buildSettingTile(title: 'Printer', value: 'Not selected', onTap: () {}),
//                 const SizedBox(height: 16),
//                 _buildSettingTile(
//                   title: 'Copies',
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove_circle_outline),
//                         onPressed: copies > 1 ? () => setState(() => copies--) : null,
//                       ),
//                       Text('$copies', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//                       IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => copies++)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildSettingTile(
//                   title: 'Orientation',
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [_buildOrientationButton(false), const SizedBox(width: 8), _buildOrientationButton(true)],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(child: _buildDropdownTile('Pages', selectedPages, () {})),
//                     const SizedBox(width: 16),
//                     Expanded(child: _buildDropdownTile('Color', selectedColor, () {})),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(child: _buildDropdownTile('Paper size', selectedPaperSize, () {})),
//                     const SizedBox(width: 16),
//                     Expanded(child: _buildDropdownTile('Print type', selectedPrintType, () {})),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Print button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print initiated')));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[400],
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
//                 ),
//                 child: const Text(
//                   'Print',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingTile({required String title, String? value, Widget? trailing, VoidCallback? onTap}) {
//     return Container(
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         trailing:
//             trailing ??
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(value ?? '', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.chevron_right),
//               ],
//             ),
//         onTap: onTap,
//       ),
//     );
//   }

//   Widget _buildDropdownTile(String title, String value, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                 Icon(Icons.expand_more, color: Colors.grey[400]),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrientationButton(bool portrait) {
//     final isSelected = isPortrait == portrait;
//     return GestureDetector(
//       onTap: () => setState(() => isPortrait = portrait),
//       child: Container(
//         width: 40,
//         height: 50,
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green : Colors.white,
//           border: Border.all(color: isSelected ? Colors.green : Colors.grey[300]!, width: 2),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Center(
//           child: Container(
//             width: portrait ? 20 : 30,
//             height: portrait ? 30 : 20,
//             decoration: BoxDecoration(
//               border: Border.all(color: isSelected ? Colors.white : Colors.grey[400]!, width: 2),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

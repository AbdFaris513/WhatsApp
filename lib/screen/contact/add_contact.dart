import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:whatsapp/controllers/chat_controller.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/utils/my_colors.dart';

class ContactPopup extends StatefulWidget {
  const ContactPopup({super.key});

  @override
  State<ContactPopup> createState() => _ContactPopupState();
}

class _ContactPopupState extends State<ContactPopup> with MyColors {
  final ChatController _chatController = Get.find<ChatController>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secoundNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool? thisPersonNotHaveAcount = false;
  String? firstNameError;
  String? phoneNumberError;

  RxString selectedCountryCode = "+91".obs;

  final InputDecoration baseDecoration = InputDecoration(
    labelStyle: const TextStyle(color: Colors.grey),
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: MyColors.massageNotificationColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'New contact',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // First Name
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: baseDecoration.copyWith(
                        labelText: 'First name',
                        errorText: firstNameError,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Last Name
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.transparent),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _secoundNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: baseDecoration.copyWith(labelText: 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Business Name
          Row(
            children: [
              const Icon(Icons.add_business, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _businessNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: baseDecoration.copyWith(labelText: 'Business name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phone Number
          Row(
            children: [
              const Icon(Icons.call_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black,
                          style: const TextStyle(color: Colors.white),
                          value: selectedCountryCode.value,
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('IN +91')),
                            DropdownMenuItem(value: '+1', child: Text('US +1')),
                            DropdownMenuItem(value: '+44', child: Text('UK +44')),
                          ],
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: baseDecoration.copyWith(
                          labelText: 'Phone',
                          errorText: phoneNumberError,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 👈 only numbers
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (thisPersonNotHaveAcount != null)
            Row(
              children: [
                Icon(
                  thisPersonNotHaveAcount == true ? Icons.cloud_done : Icons.cloud_off,
                  color: thisPersonNotHaveAcount == true ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  thisPersonNotHaveAcount == true
                      ? 'This person is on WhatsApp'
                      : 'This person does not have WhatsApp',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  firstNameError = _firstNameController.text.isEmpty
                      ? 'First name is required'
                      : null;
                  phoneNumberError = _phoneNumberController.text.isEmpty
                      ? 'Phone number is required'
                      : null;
                });

                if (firstNameError != null || phoneNumberError != null) return;

                _chatController.addContact(
                  ContactData(
                    contactFirstName: _firstNameController.text.trim(),
                    contactSecondName: _secoundNameController.text.trim(),
                    contactBusinessName: _businessNameController.text.trim(),
                    contactNumber: '$selectedCountryCode${_phoneNumberController.text.trim()}',
                  ),
                  context,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

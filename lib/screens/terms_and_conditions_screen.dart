import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../widgets/button_widget.dart';
import '../widgets/text_widget.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(
              height: 50,
            ),
            TextWidget(
              text: 'Terms and Conditions',
              fontSize: 24,
              fontFamily: 'Bold',
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''Payment and Refund Policy
All purchases made through the app are final. In accordance with Kaffi Café's policy, we enforce a strict "NO REFUND" policy once a payment has been successfully processed. For any payment disputes, complaints, or chargeback inquiries, you must contact the Kaffi Café Management directly. The developers of this application are not responsible for and will not handle any refund requests.

Table Reservation Policy
Table reservations are subject to real-time availability, which is managed directly by the Kaffi Café staff. The café is solely responsible for keeping the status of tables (e.g., for availability, maintenance, or private events) updated in the system. The developers are not liable for booking conflicts or dissatisfaction caused by operational issues at the café, including failure to update table statuses. Please arrive on time for your reservation, as late arrivals may result in the forfeiture of your table.
''',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ButtonWidget(
              label: 'Close',
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: primaryBlue,
              textColor: Colors.white,
            ),
          ]),
        ),
      ),
    );
  }
}

# Thesis Project Recommendations - Implementation Plan

This document outlines the plan to address the recommendations identified for the Kaffi-Cafe Flutter project.

## Overall Status:
We have analyzed the current codebase and confirmed the feasibility of all recommendations. The existing UI is largely suitable, but the underlying logic needs refactoring to utilize Firebase for dynamic data management and persistence.

## Recommendations and Implementation Steps:

### 1. Dynamic Vouchers (Replace Embedded Vouchers)
**Goal:** Transition from hardcoded voucher logic to a dynamic, database-driven voucher system using Firebase Firestore. This allows for easy management and updating of vouchers without app code changes.
**Current Status:** In Progress.
**Steps:**
    1.  **Create Firestore 'vouchers' Collection:** Define and create a new collection in Firebase Firestore to store voucher details (e.g., `voucherCode`, `discountType` (percentage/fixed), `discountValue`, `expiryDate`, `isActive`, `minimumOrderAmount`). - **COMPLETED** (Implemented `voucher_model.dart` and `voucher_service.dart`, integrated fetching into `checkout_screen.dart`).
    2.  **Update `VoucherConfirmationScreen` (if needed):** Ensure this screen is prepared to display dynamic voucher information. (Initially, this might not require changes, but it's good to keep in mind).
    3.  **Refactor `CheckoutScreen` to Fetch Vouchers:** Modify `lib/screens/checkout_screen.dart` to:
        *   Remove the hardcoded `_vouchers` list.
        *   Fetch available vouchers from the Firestore `vouchers` collection.
        *   Update the voucher selection dropdown to use data from Firestore.
        *   Implement logic to apply the selected dynamic voucher's discount. - **COMPLETED**

### 2. Transaction Report with Used Voucher Information
**Goal:** Ensure that when an order is confirmed, details about any applied voucher and the resulting discount are saved as part of the order transaction and can be included in printable reports.
**Current Status:** In Progress.
**Steps:**
    1.  **Update Order Saving Logic:** Modify the order confirmation process (likely in `checkout_screen.dart` and/or a related service like `order_service.dart`) to include:
        *   `voucherCodeUsed` (the code of the applied voucher)
        *   `voucherDiscountAmount` (the monetary value of the discount applied)
        *   Save these details along with other order information into the Firebase Firestore `orders` collection. - **COMPLETED** (Implemented `order_service.dart` and integrated saving into `checkout_screen.dart`).
    2.  **Generate Printable Report:** Develop or update the functionality responsible for generating reports to fetch and display the `voucherCodeUsed` and `voucherDiscountAmount` for each relevant transaction. (This step will require identifying where reports are generated).

### 3. Customizable Chatbot
**Goal:** Enable the chatbot's conversational flow and responses to be customizable, ideally via a backend service or database, rather than being hardcoded in the application.
**Current Status:** Pending.
**Steps:**
    1.  **Define Chatbot Data Structure:** Determine the structure for storing chatbot questions, answers, and conversational flows in Firebase Firestore (e.g., a `chatbot_config` collection).
    2.  **Implement Dynamic Chatbot Logic:** Modify `lib/screens/chatsupport_screen.dart` to:
        *   Fetch chatbot configuration and responses from Firestore.
        *   Dynamically generate chatbot responses based on user input and the fetched configuration.
        *   Provide a mechanism for admins to update the chatbot's script via Firebase.

---
**Next Step:** We will proceed with **Step 2 of Transaction Report: Generate Printable Report**.
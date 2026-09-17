import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod {
  upi,
  razorpay,
  cod,
}

class PaymentState {
  final PaymentMethod selectedMethod;
  final bool isProcessing;
  final String? transactionId;
  final String? errorMessage;

  const PaymentState({
    this.selectedMethod = PaymentMethod.upi,
    this.isProcessing = false,
    this.transactionId,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentMethod? selectedMethod,
    bool? isProcessing,
    String? transactionId,
    String? errorMessage,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage,
    );
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  Future<bool> processPayment({required double amount}) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1400));
    state = state.copyWith(
      isProcessing: false,
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
    );
    return true;
  }
}

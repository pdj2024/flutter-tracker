import 'package:flutter/material.dart';

class ResultWidget extends StatelessWidget {
  final String meterNumber;
  final String inputToken;
  final String outputToken;
  final String totalToken;
  final String priceIDR;
  final String priceDollar;
  final int duration;
  final VoidCallback onReset;
  const ResultWidget({
    super.key,
    required this.meterNumber,
    required this.inputToken,
    required this.outputToken,
    required this.priceIDR,
    required this.priceDollar,
    required this.onReset,
    required this.totalToken,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Color(0xff2fd5f2).withAlpha(30),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Result",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text("${duration} seconds", style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Meter number", style: TextStyle(fontSize: 14)),
                Text(
                  meterNumber,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Token Amount", style: TextStyle(fontSize: 14)),
                Text(
                  totalToken,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2fd5f2),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Price", style: TextStyle(fontSize: 14)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$ $priceDollar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "Rp $priceIDR",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: onReset,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade500),
                ),
                child: Center(
                  child: Text(
                    'Upload another image',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

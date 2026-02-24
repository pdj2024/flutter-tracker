import 'package:flutter/material.dart';

class ResultWidget extends StatefulWidget {
  final String meterNumber;
  final String inputToken;
  final String outputToken;
  final String totalToken;
  final String priceIDR;
  final String priceDollar;
  final int durationGPT;
  final int durationCompress;
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
    required this.durationGPT,
    required this.durationCompress,
  });

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.durationGPT + widget.durationCompress;
    
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
                // Duration dengan expand/collapse
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xffe6f7fa),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Color(0xff10bddc),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "$totalDuration sec",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff10bddc),
                          ),
                        ),
                        SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Color(0xff10bddc),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Detail duration (expandable)
            AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDurationRow(
                      icon: Icons.compress,
                      label: "Compress",
                      duration: widget.durationCompress,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 8),
                    _buildDurationRow(
                      icon: Icons.document_scanner_outlined,
                      label: "OCR Process",
                      duration: widget.durationGPT,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 200),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Meter number", style: TextStyle(fontSize: 14)),
                Text(
                  widget.meterNumber,
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
                  widget.totalToken,
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
                      "\$ ${widget.priceDollar}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "Rp ${widget.priceIDR}",
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
              onTap: widget.onReset,
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

  Widget _buildDurationRow({
    required IconData icon,
    required String label,
    required int duration,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
        Text(
          "$duration sec",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
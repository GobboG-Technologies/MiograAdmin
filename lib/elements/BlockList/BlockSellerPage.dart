import 'package:flutter/material.dart';

class blockSellerPage extends StatelessWidget {
  final List<Map<String, String>> sellerData = [
    {
      "name": "Abilash",
      "id": "SID98765432101",
      "phone": "+91 9876543210",
      "email": "abilashabi@gmail.com",
      "address": "TMJ complex, Tamil Nadu",
      "image": "assets/images/img5.png"
    },
    {
      "name": "John Doe",
      "id": "SID123456789",
      "phone": "+91 9876543211",
      "email": "johndoe@gmail.com",
      "address": "MG Road, Bangalore",
      "image": "assets/images/img5.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: sellerData.length,
      itemBuilder: (context, index) {
        var seller = sellerData[index];
        return _buildCard(seller);
      },
    );
  }

  Widget _buildCard(Map<String, String> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(data["image"]!, width: 200, height: 200, fit: BoxFit.cover),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data["name"]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("ID: ${data["id"]}", style: TextStyle(color: Colors.purple[900], fontSize: 12)),
                    SizedBox(height: 5),
                    Text(data["phone"]!, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 5),
                    Text(data["email"]!, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 5),
                    Text("● Blocked", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(data["address"]!, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(child: SizedBox()),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple[900],
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Center(
              child: Text("✎ Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

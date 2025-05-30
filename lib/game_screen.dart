import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';




class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Aircraft> aircraftList = [];
  List<Aircraft> filteredList = [];
  List<Aircraft> favoriteAircraft = [];
  String selectedCategory = 'ALL';
  int currentIndex = 0;
  TextEditingController searchController = TextEditingController();
  Map<String, String> userProfile = {
    'firstName': '',
    'lastName': '',
    'username': '',
    'dob': '',
  };
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadAircraftData();
    searchController.addListener(_filterAircraft);
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userProfile = {
        'firstName': prefs.getString('firstName') ?? '',
        'lastName': prefs.getString('lastName') ?? '',
        'username': prefs.getString('username') ?? '',
        'dob': prefs.getString('dob') ?? '',
      };
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firstName', userProfile['firstName']!);
      await prefs.setString('lastName', userProfile['lastName']!);
      await prefs.setString('username', userProfile['username']!);
      await prefs.setString('dob', userProfile['dob']!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  void loadAircraftData() {
    final jsonData = '''
    {
      "aircraft": [
        {
          "id": 1,
          "name": "F-22 RAPTOR",
          "subtitle": "STEALTH MULTIROLE FIGHTER",
          "overview": {
            "type": "Stealth Multirole Fighter",
            "manufacturer": "Lockheed Martin",
            "firstFlight": "September 7, 1997",
            "role": "Air superiority, ground strike, intelligence, and surveillance"
          },
          "tags": ["STEALTH", "5TH GEN", "SUPERCRUISE"],
          "category": "MILITARY",
          "specifications": {
            "topSpeed": "Mach 2.25",
            "range": "2,963 km",
            "engines": "2 × Pratt & Whitney F119-PW-100",
            "serviceCeiling": "19,812 m",
            "crew": "1"
          }
        },
        {
          "id": 2,
          "name": "F-35 LIGHTNING II",
          "subtitle": "JOINT STRIKE FIGHTER",
          "overview": {
            "type": "Multirole Stealth Fighter",
            "manufacturer": "Lockheed Martin",
            "firstFlight": "December 15, 2006",
            "role": "Air-to-air combat, air-to-ground strike, electronic warfare"
          },
          "tags": ["STEALTH", "5TH GEN", "VTOL"],
          "category": "MILITARY",
          "specifications": {
            "topSpeed": "Mach 1.6",
            "range": "2,220 km",
            "engines": "1 × Pratt & Whitney F135",
            "serviceCeiling": "15,240 m",
            "crew": "1"
          }
        },
        {
          "id": 3,
          "name": "B-2 SPIRIT",
          "subtitle": "STEALTH STRATEGIC BOMBER",
          "overview": {
            "type": "Flying Wing Stealth Bomber",
            "manufacturer": "Northrop Grumman",
            "firstFlight": "July 17, 1989",
            "role": "Strategic nuclear & conventional bombing"
          },
          "tags": ["STEALTH", "FLYING WING", "NUCLEAR"],
          "category": "MILITARY",
          "specifications": {
            "topSpeed": "Mach 0.95",
            "range": "~11,000 km",
            "engines": "4 × General Electric F118-GE-100",
            "serviceCeiling": "15,200 m",
            "crew": "2"
          }
        },
        {
          "id": 4,
          "name": "BOEING 747",
          "subtitle": "WIDE-BODY AIRLINER",
          "overview": {
            "type": "Long-Range Wide-Body Airliner",
            "manufacturer": "Boeing",
            "firstFlight": "February 9, 1969",
            "role": "Long-haul passenger transport, cargo operations"
          },
          "tags": ["COMMERCIAL", "JUMBO JET", "ICONIC"],
          "category": "COMMERCIAL",
          "specifications": {
            "topSpeed": "Mach 0.92",
            "range": "14,815 km",
            "engines": "4 × Turbofan",
            "serviceCeiling": "13,746 m",
            "crew": "2-3"
          }
        },
        {
          "id": 5,
          "name": "AIRBUS A320",
          "subtitle": "NARROW-BODY AIRLINER",
          "overview": {
            "type": "Short to Medium-Range Airliner",
            "manufacturer": "Airbus",
            "firstFlight": "February 22, 1987",
            "role": "Passenger transport, regional operations"
          },
          "tags": ["COMMERCIAL", "FLY-BY-WIRE", "EFFICIENT"],
          "category": "COMMERCIAL",
          "specifications": {
            "topSpeed": "Mach 0.82",
            "range": "6,150 km",
            "engines": "2 × Turbofan",
            "serviceCeiling": "12,500 m",
            "crew": "2"
          }
        }
      ]
    }
    ''';

    final data = json.decode(jsonData);
    aircraftList = (data['aircraft'] as List)
        .map((item) => Aircraft.fromJson(item))
        .toList();
    filteredList = aircraftList;
    setState(() {});
  }

  void _filterAircraft() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredList = aircraftList.where((aircraft) {
        bool matchesSearch = aircraft.name.toLowerCase().contains(query) ||
            aircraft.subtitle.toLowerCase().contains(query);
        bool matchesCategory =
            selectedCategory == 'ALL' || aircraft.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      _filterAircraft();
    });
  }

  void _toggleFavorite(Aircraft aircraft) {
    setState(() {
      if (favoriteAircraft.contains(aircraft)) {
        favoriteAircraft.remove(aircraft);
      } else {
        favoriteAircraft.add(aircraft);
      }
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: [
            // Home Screen
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVIAWIKI',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Roboto Mono'),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontFamily: 'Roboto Mono'),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'FEATURED AIRCRAFT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 250,
                      child: PageView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    aircraft: filteredList[index],
                                    onToggleFavorite: _toggleFavorite,
                                    isFavorite: favoriteAircraft
                                        .contains(filteredList[index]),
                                  ),
                                ),
                              );
                            },
                            child: FeaturedAircraftCard(
                                aircraft: filteredList[index]),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'CATEGORIES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        CategoryButton(
                          title: 'MILITARY',
                          isSelected: selectedCategory == 'MILITARY',
                          onTap: () => _selectCategory('MILITARY'),
                        ),
                        SizedBox(width: 12),
                        CategoryButton(
                          title: 'COMMERCIAL',
                          isSelected: selectedCategory == 'COMMERCIAL',
                          onTap: () => _selectCategory('COMMERCIAL'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'AIRCRAFT OF THE WEEK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 12),
                    Column(
                      children: filteredList
                          .map((aircraft) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        aircraft: aircraft,
                                        onToggleFavorite: _toggleFavorite,
                                        isFavorite:
                                            favoriteAircraft.contains(aircraft),
                                      ),
                                    ),
                                  );
                                },
                                child: AircraftListCard(
                                  aircraft: aircraft,
                                  imagePath: 'assets/${aircraft.id}.png',
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Favorites Screen
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FAVORITES',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: favoriteAircraft.isEmpty
                        ? Center(
                            child: Text(
                              'No favorites yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Roboto Mono',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: favoriteAircraft.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        aircraft: favoriteAircraft[index],
                                        onToggleFavorite: _toggleFavorite,
                                        isFavorite: true,
                                      ),
                                    ),
                                  );
                                },
                                child: AircraftListCard(
                                  aircraft: favoriteAircraft[index],
                                  imagePath:
                                      'assets/${favoriteAircraft[index].id}.png',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            // Settings Screen
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  SizedBox(height: 30),
                  ListTile(
                    title: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () => _launchURL(
                        'https://docs.google.com/document/d/1SwQaNyPItwrGDaywpsexmBFN5ee6y-FwerB2eAmCNs0/edit?usp=sharing'),
                  ),
                ],
              ),
            ),
            // Profile Screen
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      initialValue: userProfile['firstName'],
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onSaved: (value) =>
                          userProfile['firstName'] = value ?? '',
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: userProfile['lastName'],
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onSaved: (value) => userProfile['lastName'] = value ?? '',
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: userProfile['username'],
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onSaved: (value) => userProfile['username'] = value ?? '',
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: userProfile['dob'],
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Date of Birth (DD-MM-YYYY)',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onSaved: (value) => userProfile['dob'] = value ?? '',
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          'SAVE PROFILE',
                          style: TextStyle(
                            fontFamily: 'Roboto Mono',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeaturedAircraftCard extends StatelessWidget {
  final Aircraft aircraft;

  FeaturedAircraftCard({required this.aircraft});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.red.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  child: Center(
                    child: Image.asset(
                      'assets/${aircraft.id}.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  aircraft.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto Mono',
                  ),
                ),
                Text(
                  aircraft.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontFamily: 'Roboto Mono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AircraftListCard extends StatelessWidget {
  final Aircraft aircraft;
  final String imagePath;

  AircraftListCard({required this.aircraft, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 80,
                height: 60,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aircraft.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    Text(
                      aircraft.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.airplanemode_active,
                            size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          aircraft.specifications.topSpeed,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontFamily: 'Roboto Mono',
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.linear_scale, size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          aircraft.specifications.range,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontFamily: 'Roboto Mono',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  CategoryButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto Mono',
          ),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final Aircraft aircraft;
  final Function(Aircraft)? onToggleFavorite;
  final bool isFavorite;

  DetailsScreen({
    required this.aircraft,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.red, size: 24),
                  ),
                  Text(
                    'DETAILS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleFavorite != null
                        ? () => onToggleFavorite!(aircraft)
                        : null,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.0,
                                colors: [
                                  Colors.red.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              'assets/${aircraft.id}.png',
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      aircraft.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    Text(
                      aircraft.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'OVERVIEW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Type', aircraft.overview.type),
                    _buildDetailRow(
                        'Manufacturer', aircraft.overview.manufacturer),
                    _buildDetailRow(
                        'First Flight', aircraft.overview.firstFlight),
                    _buildDetailRow('Role', aircraft.overview.role),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: aircraft.tags
                          .map((tag) => Chip(
                                label: Text(
                                  tag,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Roboto Mono',
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'SPECIFICATIONS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                        'Top Speed', aircraft.specifications.topSpeed),
                    _buildDetailRow('Range', aircraft.specifications.range),
                    _buildDetailRow('Engines', aircraft.specifications.engines),
                    _buildDetailRow('Service Ceiling',
                        aircraft.specifications.serviceCeiling),
                    _buildDetailRow('Crew', aircraft.specifications.crew),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto Mono',
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto Mono',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Aircraft {
  final int id;
  final String name;
  final String subtitle;
  final Overview overview;
  final List<String> tags;
  final String category;
  final Specifications specifications;

  Aircraft({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.overview,
    required this.tags,
    required this.category,
    required this.specifications,
  });

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'],
      overview: Overview.fromJson(json['overview']),
      tags: List<String>.from(json['tags']),
      category: json['category'],
      specifications: Specifications.fromJson(json['specifications']),
    );
  }
}

class Overview {
  final String type;
  final String manufacturer;
  final String firstFlight;
  final String role;

  Overview({
    required this.type,
    required this.manufacturer,
    required this.firstFlight,
    required this.role,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      type: json['type'],
      manufacturer: json['manufacturer'],
      firstFlight: json['firstFlight'],
      role: json['role'],
    );
  }
}

class Specifications {
  final String topSpeed;
  final String range;
  final String engines;
  final String serviceCeiling;
  final String crew;

  Specifications({
    required this.topSpeed,
    required this.range,
    required this.engines,
    required this.serviceCeiling,
    required this.crew,
  });

  factory Specifications.fromJson(Map<String, dynamic> json) {
    return Specifications(
      topSpeed: json['topSpeed'],
      range: json['range'],
      engines: json['engines'],
      serviceCeiling: json['serviceCeiling'],
      crew: json['crew'],
    );
  }
}

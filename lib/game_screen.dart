import 'package:avia/news.dart';
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
  List<NewsItem> newsList = [];
  List<NewsItem> filteredNews = [];
  String selectedNewsCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    loadAircraftData();
    loadNewsData();
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

  void loadNewsData() {
    final jsonData = '''
    {
      "news": [
        {
          "id": 1,
          "title": "Boeing 787 Dreamliner Achieves New Fuel Efficiency Record",
          "summary": "Latest tests show the Boeing 787 achieving unprecedented fuel efficiency on long-haul routes, setting new industry standards for sustainable aviation.",
          "content": "The Boeing 787 Dreamliner has set a new benchmark in aviation fuel efficiency during recent long-haul flight tests. The aircraft demonstrated a 20% improvement in fuel consumption compared to previous generation wide-body aircraft.\\n\\nThis achievement comes as the aviation industry continues to focus on reducing carbon emissions and improving operational efficiency. The 787's composite construction and advanced aerodynamics contribute significantly to these impressive results.\\n\\nAirlines operating the 787 are reporting substantial cost savings on fuel expenses, with some carriers seeing reductions of up to \$3 million annually per aircraft on long-haul routes.\\n\\nThe success of the 787 program demonstrates the importance of continuous innovation in aircraft design and manufacturing, paving the way for even more efficient aircraft in the future.",
          "category": "COMMERCIAL",
          "publishedDate": "June 2, 2025",
          "source": "Aviation Week",
          "tags": ["Boeing", "Efficiency", "Sustainable", "787"]
        },
        {
          "id": 2,
          "title": "F-35 Lightning II Receives Major Software Update",
          "summary": "The latest Block 4 software update for the F-35 fighter jet introduces enhanced combat capabilities and improved sensor fusion technology.",
          "content": "Lockheed Martin has successfully deployed the highly anticipated Block 4 software update for the F-35 Lightning II, marking a significant milestone in the aircraft's evolution.\\n\\nThe update introduces advanced threat detection algorithms, improved electronic warfare capabilities, and enhanced data sharing between aircraft in formation. Pilots report significantly improved situational awareness and target acquisition speed.\\n\\nKey improvements include a 40% increase in processing speed for sensor data, new countermeasure systems, and compatibility with next-generation weapons systems. The update also addresses previous concerns about helmet display lag and targeting accuracy.\\n\\nThis software enhancement solidifies the F-35's position as the world's most advanced multirole fighter, with several allied nations expressing interest in accelerating their procurement timelines.",
          "category": "MILITARY",
          "publishedDate": "June 1, 2025",
          "source": "Defense News",
          "tags": ["F35", "Military", "Software", "Combat"]
        },
        {
          "id": 3,
          "title": "Supersonic Passenger Flight Tests Show Promising Results",
          "summary": "Recent test flights of next-generation supersonic aircraft demonstrate significant progress toward commercial supersonic passenger services.",
          "content": "The future of supersonic passenger travel moved closer to reality this week as multiple aerospace companies reported successful test flights of their next-generation aircraft designs.\\n\\nBoom Supersonic's Overture prototype achieved Mach 1.7 during its latest test flight, while maintaining noise levels significantly below previous supersonic aircraft. The company reports that sonic boom signatures have been reduced by 75% compared to the Concorde.\\n\\nSimilarly, Aerion's AS2 business jet completed its first supersonic cruise, demonstrating stable flight characteristics and efficient fuel consumption at high speeds. The aircraft utilizes advanced materials and engine technologies to achieve these performance improvements.\\n\\nRegulatory authorities in the US and Europe are reviewing updated noise standards that could pave the way for overland supersonic flights, potentially revolutionizing long-distance travel within the next decade.",
          "category": "TECHNOLOGY",
          "publishedDate": "May 30, 2025",
          "source": "FlightGlobal",
          "tags": ["Supersonic", "Technology", "Future", "Testing"]
        },
        {
          "id": 4,
          "title": "Electric Aircraft Breakthrough: 500-Mile Range Achieved",
          "summary": "A revolutionary electric aircraft has successfully completed a 500-mile flight, marking a major milestone in sustainable aviation technology.",
          "content": "Wright Electric's prototype passenger aircraft has achieved a groundbreaking 500-mile flight on battery power alone, representing the longest electric flight by a commercial-sized aircraft to date.\\n\\nThe flight utilized next-generation lithium-sulfur batteries with three times the energy density of conventional lithium-ion cells. The aircraft carried the equivalent of 50 passengers for the entire journey without requiring a recharge.\\n\\nThis achievement brings electric aviation significantly closer to commercial viability for regional routes. Airlines are already expressing interest in electric aircraft for short-haul flights, which represent 30% of all commercial aviation emissions.\\n\\nThe successful test flight demonstrates that electric propulsion could revolutionize regional air travel within the next five years, offering zero-emission flights for distances up to 500 miles.",
          "category": "TECHNOLOGY",
          "publishedDate": "May 28, 2025",
          "source": "Electric Aviation News",
          "tags": ["Electric", "Sustainable", "Battery", "Innovation"]
        },
        {
          "id": 5,
          "title": "NASA's X-59 Quiet Supersonic Aircraft Completes First Public Flight",
          "summary": "NASA's experimental X-59 aircraft designed to reduce sonic booms has completed its first flight over populated areas as part of the QueSST mission.",
          "content": "NASA's X-59 Quiet SuperSonic Technology (QueSST) aircraft has successfully completed its first flight over populated areas, generating crucial data about reduced sonic boom signatures.\\n\\nThe flight over Palmdale, California, was monitored by ground-based sensors and community volunteers who reported that the aircraft's sonic signature was barely perceptible, described as a 'gentle thump' rather than the traditional sharp crack of a sonic boom.\\n\\nThe X-59's unique design, featuring a pointed nose and specific wing configuration, shapes the shock waves to reduce the intensity of sonic booms by up to 75%. This technology could enable the return of overland supersonic passenger flights.\\n\\nNASA plans to conduct similar flights over multiple communities across the United States to gather comprehensive data on public acceptance of reduced sonic boom signatures. The results will inform future regulations for commercial supersonic flight.",
          "category": "RESEARCH",
          "publishedDate": "May 26, 2025",
          "source": "NASA News",
          "tags": ["NASA", "X59", "Research", "Supersonic"]
        },
        {
          "id": 6,
          "title": "Airbus A350 Sets New Transatlantic Speed Record",
          "summary": "An Airbus A350-1000 has broken the transatlantic speed record for commercial aircraft, completing the journey in record time with favorable winds.",
          "content": "British Airways' Airbus A350-1000 has set a new transatlantic speed record, completing the journey from New York to London in just 4 hours and 56 minutes, breaking the previous record held by a Boeing 747.\\n\\nThe flight took advantage of exceptionally strong jet stream winds reaching up to 250 mph, allowing the aircraft to achieve ground speeds of over 825 mph while maintaining normal cruise speed through the air.\\n\\nThe A350's advanced flight management systems and efficient twin-engine design played a crucial role in optimizing the flight path and fuel consumption during the record-breaking journey.\\n\\nThis achievement highlights the continued evolution of commercial aviation efficiency and the importance of weather routing in modern flight operations. The record demonstrates how advanced aircraft systems can take advantage of natural phenomena to achieve remarkable performance.",
          "category": "COMMERCIAL",
          "publishedDate": "May 24, 2025",
          "source": "Airways Magazine",
          "tags": ["Airbus", "A350", "Record", "Speed"]
        }
      ]
    }
    ''';

    final data = json.decode(jsonData);
    newsList =
        (data['news'] as List).map((item) => NewsItem.fromJson(item)).toList();
    filteredNews = newsList;
  }

  void _filterNews() {
    setState(() {
      filteredNews = newsList.where((news) {
        bool matchesCategory = selectedNewsCategory == 'ALL' ||
            news.category == selectedNewsCategory;
        return matchesCategory;
      }).toList();
    });
  }

  void _selectNewsCategory(String category) {
    setState(() {
      selectedNewsCategory = category;
      _filterNews();
    });
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
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVIATION NEWS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CategoryButton(
                            title: 'ALL',
                            isSelected: selectedNewsCategory == 'ALL',
                            onTap: () => _selectNewsCategory('ALL'),
                          ),
                          SizedBox(width: 8),
                          CategoryButton(
                            title: 'COMMERCIAL',
                            isSelected: selectedNewsCategory == 'COMMERCIAL',
                            onTap: () => _selectNewsCategory('COMMERCIAL'),
                          ),
                          SizedBox(width: 8),
                          CategoryButton(
                            title: 'MILITARY',
                            isSelected: selectedNewsCategory == 'MILITARY',
                            onTap: () => _selectNewsCategory('MILITARY'),
                          ),
                          SizedBox(width: 8),
                          CategoryButton(
                            title: 'TECHNOLOGY',
                            isSelected: selectedNewsCategory == 'TECHNOLOGY',
                            onTap: () => _selectNewsCategory('TECHNOLOGY'),
                          ),
                          SizedBox(width: 8),
                          CategoryButton(
                            title: 'RESEARCH',
                            isSelected: selectedNewsCategory == 'RESEARCH',
                            onTap: () => _selectNewsCategory('RESEARCH'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'LATEST NEWS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: filteredNews
                          .map<Widget>((news) => NewsCard(
                                news: news,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NewsDetailScreen(news: news),
                                    ),
                                  );
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
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

class DetailsScreen extends StatefulWidget {
  final Aircraft aircraft;
  final Function(Aircraft)? onToggleFavorite;
  bool isFavorite;

  DetailsScreen({
    required this.aircraft,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
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
                    onTap: () {
                      if (widget.onToggleFavorite != null) {
                        widget.onToggleFavorite!(widget.aircraft);
                      }

                      // Обновляем состояние
                      setState(() {
                        widget.isFavorite =
                            !widget.isFavorite; // Инвертируем значение
                      });
                    },
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
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
                              'assets/${widget.aircraft.id}.png',
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      widget.aircraft.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                    Text(
                      widget.aircraft.subtitle,
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
                    _buildDetailRow('Type', widget.aircraft.overview.type),
                    _buildDetailRow(
                        'Manufacturer', widget.aircraft.overview.manufacturer),
                    _buildDetailRow(
                        'First Flight', widget.aircraft.overview.firstFlight),
                    _buildDetailRow('Role', widget.aircraft.overview.role),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: widget.aircraft.tags
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
                        'Top Speed', widget.aircraft.specifications.topSpeed),
                    _buildDetailRow(
                        'Range', widget.aircraft.specifications.range),
                    _buildDetailRow(
                        'Engines', widget.aircraft.specifications.engines),
                    _buildDetailRow('Service Ceiling',
                        widget.aircraft.specifications.serviceCeiling),
                    _buildDetailRow(
                        'Crew', widget.aircraft.specifications.crew),
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

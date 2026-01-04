import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../presentation/state/settings_store.dart';

class ContactPersonPage extends StatefulWidget {
  const ContactPersonPage({super.key});

  @override
  State<ContactPersonPage> createState() => _ContactPersonPageState();
}

class Person {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String imageUrl;
  bool isAvailable;
  int rating;

  Person({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.imageUrl,
    this.isAvailable = true,
    this.rating = 0,
  });
}

class _ContactPersonPageState extends State<ContactPersonPage> {
  List<Person> persons = [
    Person(
      name: 'Alice Johnson',
      role: 'Designer',
      email: 'alice@example.com',
      phone: '+123456789',
      imageUrl:
          'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/female/512/50.jpg',
    ),
    Person(
      name: 'Bob Smith',
      role: 'Developer',
      email: 'bob@example.com',
      phone: '+987654321',
      imageUrl:
          'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/50.jpg',
    ),
    Person(
      name: 'Charlie Brown',
      role: 'Manager',
      email: 'charlie@example.com',
      phone: '+192837465',
      imageUrl:
          'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/90.jpg',
    ),
  ];

  int selectedIndex = 0;
  String searchQuery = '';
  bool isSidebarOpen = true;

  List<Person> get filteredPersons => persons
      .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  Person? get selectedPerson => filteredPersons.isNotEmpty
      ? filteredPersons[selectedIndex.clamp(0, filteredPersons.length - 1)]
      : null;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<SettingsStore>(context);
    final t = store.translations; // JSON translations
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(t.of('contact_person')),
        backgroundColor: kAppBarColor,
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(t),
          Expanded(
            child: selectedPerson != null
                ? _buildPersonDetails(selectedPerson!, t)
                : Center(
                    child: Text(
                      t.of('no_person_found'),
                      style: TextStyle(color: kTextSecondaryColor),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ========================== SIDEBAR ==========================
Widget _buildSidebar(t) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSidebarOpen ? 280 : 60,
      color: kPrimaryColor,
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              isSidebarOpen ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              color: kTextLightColor,
            ),
            onPressed: () {
              setState(() {
                isSidebarOpen = !isSidebarOpen;
              });
            },
          ),
          if (isSidebarOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    selectedIndex = 0;
                  });
                },
                style: TextStyle(color: kTextDarkColor),
                decoration: InputDecoration(
                  hintText: t.of('search'),
                  hintStyle: TextStyle(color: kTextSecondaryColor),
                  prefixIcon: Icon(Icons.search, color: kIconColor),
                  filled: true,
                  fillColor: kCardBackgroundColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPersons.length,
              itemBuilder: (_, i) {
                final p = filteredPersons[i];
                final isSelected = i == selectedIndex;

                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
                  title: isSidebarOpen
                      ? Text(
                          p.name,
                          style: TextStyle(
                              color: isSelected ? kCategoryAmber : kTextLightColor),
                        )
                      : null,
                  subtitle: isSidebarOpen
                      ? Text(p.role, style: TextStyle(color: kTextSecondaryColor))
                      : null,
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ========================== PERSON DETAILS ==========================
  Widget _buildPersonDetails(Person person, t){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 50, backgroundImage: NetworkImage(person.imageUrl)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kTextDarkColor),
                  ),
                  Text(
                    person.role,
                    style: TextStyle(fontSize: 16, color: kTextSecondaryColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildContactRow(Icons.email, person.email, 'mailto:${person.email}'),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone, person.phone, 'tel:${person.phone}'),
          const SizedBox(height: 24),
          Row(
            children: List.generate(5, (i) {
              return InkWell(
                onTap: () {
                  setState(() {
                    person.rating = i + 1;
                  });
                },
                child: Icon(
                  i < person.rating ? Icons.star : Icons.star_border,
                  color: kCategoryAmber,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, String url) {
    return Row(
      children: [
        Icon(icon, color: kIconColor),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => launchUrl(Uri.parse(url)),
          child: Text(
            text,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: kTextDarkColor,
            ),
          ),
        ),
      ],
    );
  }
}

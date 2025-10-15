import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcadia Bay Grocer',
      theme: ThemeData(
        // Default accents black; progress bar green
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.black,
          textColor: Colors.black,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Arcadia Bay Grocer'),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Responsive sizing so the layout looks consistent on phones and desktops.
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width < 600
        ? 16
        : (width < 1024)
        ? 24
        : 32;
    const double maxContentWidth = 900;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content centered with max width and adaptive padding
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Narrow progression tracker under the title
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: const [
                            // simulated progress for checklist progression bar.
                            _ProgressTracker(progress: 0.45),
                            SizedBox(height: 8),
                            Text(
                              'Progression bar placeholder here - currently at 45%',
                            ),
                          ],
                        ),
                      ),

                      // Narrow 'filter' container with four buttons
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _ActionBar(),
                      ),

                      // Large space in the middle for grocery list
                      const Expanded(child: _DataList()),

                      // Bottom spacer so corner icons don't overlap end of the grocery list
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-left shopping cart icon: navigates to Add Items page (placeholder)
            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 12),
                child: _CornerIconButton(
                  key: const ValueKey('bottomLeftIcon'),
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddItemsPage()),
                    );
                  },
                ),
              ),
            ),

            // Bottom-right barcode scanner icon: navigates to Barcode Scanner page (placeholder)
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 32, bottom: 12),
                child: _CornerIconButton(
                  key: const ValueKey('bottomRightIcon'),
                  icon: Icons.barcode_reader,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BarcodeScannerPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTracker extends StatelessWidget {
  const _ProgressTracker({required this.progress});

  final double progress; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    // Progression bar should be green
    const color = Colors.green;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
        ),
        child: LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: Colors.transparent,
          minHeight: 10,
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar();
  @override
  Widget build(BuildContext context) {
    // Four placeholder filter buttons.
    final buttons = <Widget>[
      // Button: Meats
      _SmallButton(label: 'Meats', icon: Icons.agriculture, onPressed: () {}),
      // Button: Produce
      _SmallButton(label: 'Produce', icon: Icons.eco_sharp, onPressed: () {}),
      // Button: Beverages
      _SmallButton(
        label: 'Beverages',
        icon: Icons.local_drink,
        onPressed: () {},
      ),
      // Button: Misc
      _SmallButton(
        label: 'Misc',
        icon: Icons.question_mark_rounded,
        onPressed: () {},
      ),
    ];

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            Expanded(child: buttons[i]),
            if (i != buttons.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Button widget for items in the filter row.
    // Using a vertical (column) layout so the label has more room and doesn't overflow.
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DataList extends StatelessWidget {
  const _DataList();

  @override
  Widget build(BuildContext context) {
    // Placeholder list of grocery items added to list
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item #${index + 1}'),
          subtitle: const Text('Item details go here'),
          // white on black background for icon colors
          leading: const CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.shopping_bag, color: Colors.white),
          ),
          onTap: () {},
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: 5,
    );
  }
}

class _CornerIconButton extends StatelessWidget {
  const _CornerIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // white on black background for icon colors
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Padding to add more room inside the pill around icon.
      padding: const EdgeInsets.all(6), // was 6
      // Actual corner icon button widget.
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        // padding inside the icon.
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        onPressed: onPressed,
        tooltip: 'Hover over (or long press) for button action',
      ),
    );
  }
}

// Placeholder screen for adding items by searching.
class AddItemsPage extends StatelessWidget {
  const AddItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Items')),
      body: const Center(
        child: Text(
          'Add Items screen placeholder\n(Here you will search to add items)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Placeholder screen for barcode scanning.
class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: const Center(
        child: Text(
          'Barcode Scanner screen placeholder\n(Here you will scan barcodes)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

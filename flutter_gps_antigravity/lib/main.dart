import 'package:flutter/material.dart';
import 'location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BG-Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0C10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF00F2FE),
          surface: Color(0xFF16181F),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado
            _buildHeader(),
            
            // Cuerpo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card del mapa mockup
                    _buildMapCard(),
                    const SizedBox(height: 20),
                    
                    // Estadísticas de tracking
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    
                    // Botones de acción
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    
                    // Historial de Ubicaciones
                    _buildHistoryCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header con fondo y badge de estado
  Widget _buildHeader() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF3F3B56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Área del Logo
          Row(
            children: [
              const Icon(
                Icons.navigation,
                color: Color(0xFF00F2FE),
                size: 28,
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFA5B4FC)],
                ).createShader(bounds),
                child: const Text(
                  'BG-Tracker',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          // Badge del estado de tracking
          ValueListenableBuilder<bool>(
            valueListenable: _locationService.isTracking,
            builder: (context, isTracking, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isTracking
                      ? const Color(0xFF10B981).withOpacity(0.08)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: isTracking
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : Colors.white.withOpacity(0.08),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Punto pulsante / estático
                    isTracking
                        ? AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.6),
                                      blurRadius: 4 + _pulseController.value * 6,
                                      spreadRadius: _pulseController.value * 3,
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                    const SizedBox(width: 8),
                    Text(
                      isTracking ? 'RASTREANDO' : 'DETENIDO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isTracking ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // Card con el mapa de seguimiento
  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16181F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.map_outlined, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 10),
              Text(
                'Ruta en Tiempo Real',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E7FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/map_mockup.png',
                    fit: BoxFit.cover,
                  ),
                  // Overlay animado para simular pin pulsante
                  ValueListenableBuilder<bool>(
                    valueListenable: _locationService.isTracking,
                    builder: (context, isTracking, child) {
                      if (!isTracking) return const SizedBox.shrink();
                      return Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00F2FE),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 8 + (12 * _pulseController.value),
                                  height: 8 + (12 * _pulseController.value),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00F2FE).withOpacity(1.0 - _pulseController.value),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Grid de estadísticas
  Widget _buildStatsGrid() {
    return ValueListenableBuilder<List<SavedLocation>>(
      valueListenable: _locationService.locations,
      builder: (context, locationsList, child) {
        String latestCoords = 'Ninguna';
        if (locationsList.isNotEmpty) {
          // Ajuste 1: Separar latitud y longitud con un salto de línea (\n) en lugar de una coma
          latestCoords = "${locationsList.first.latitude.toStringAsFixed(6)}\n${locationsList.first.longitude.toStringAsFixed(6)}";
        }

        return Row(
          children: [
            // Total Registros
            Expanded(
              flex: 1,
              child: Container(
                height: 95, // Subimos sutilmente a 95 para dar más aire vertical uniforme
                decoration: BoxDecoration(
                  color: const Color(0xFF16181F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding optimizado
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'REGISTROS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF818CF8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${locationsList.length}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Última ubicación
            Expanded(
              flex: 2,
              child: Container(
                height: 95, // Mismo alto simétrico
                decoration: BoxDecoration(
                  color: const Color(0xFF16181F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding optimizado
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ÚLTIMA UBICACIÓN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF818CF8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Ajuste 2: FittedBox para asegurar escalado perfecto sin overflow
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            latestCoords,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF38BDF8),
                              fontFamily: 'monospace',
                              height: 1.2, // Controla el espaciado entre las dos líneas
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Botones de acción (Iniciar/Detener y Limpiar)
  Widget _buildActionButtons() {
    return ValueListenableBuilder<bool>(
      valueListenable: _locationService.isTracking,
      builder: (context, isTracking, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón de encendido/apagado con gradiente
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isTracking
                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                      : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isTracking ? const Color(0xFFEF4444) : const Color(0xFF6366F1)).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (isTracking) {
                    _locationService.stopBackgroundTracking();
                  } else {
                    _locationService.startBackgroundTracking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTracking ? Icons.stop_circle_outlined : Icons.play_circle_fill,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTracking ? 'Detener Servicio' : 'Iniciar GPS',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón limpiar historial
            ValueListenableBuilder<List<SavedLocation>>(
              valueListenable: _locationService.locations,
              builder: (context, locationsList, child) {
                final hasHistory = locationsList.isNotEmpty;
                return SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: hasHistory ? _locationService.clearHistory : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: hasHistory ? Colors.white12 : Colors.white10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: hasHistory ? const Color(0xFF9CA3AF) : Colors.white24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Limpiar Historial',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasHistory ? const Color(0xFF9CA3AF) : Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Card con el historial de ubicaciones
  Widget _buildHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16181F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.list_alt_rounded, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 10),
              Text(
                'Historial de Ubicaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E7FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ValueListenableBuilder<List<SavedLocation>>(
            valueListenable: _locationService.locations,
            builder: (context, locationsList, child) {
              if (locationsList.isEmpty) {
                return _buildEmptyState();
              }
              
              return Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: locationsList.length,
                  itemBuilder: (context, index) {
                    final loc = locationsList[index];
                    final itemNumber = locationsList.length - index;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.015),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "#$itemNumber",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lat: ${loc.latitude.toStringAsFixed(6)}, Lng: ${loc.longitude.toStringAsFixed(6)}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF3F4F6),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Registrado a las ${loc.formattedTime}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Vista cuando no hay datos
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        children: const [
          Icon(
            Icons.location_off_outlined,
            color: Color(0xFF4B5563),
            size: 40,
          ),
          SizedBox(height: 12),
          Text(
            'No hay ubicaciones registradas aún.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Presiona "Iniciar GPS" y desplázate o minimiza la app para comenzar el registro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

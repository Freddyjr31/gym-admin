# 🧁 Gym Admin — Gestión de Recetas y Costos

Aplicación de escritorio desarrollada en **Flutter** para Windows, diseñada para:

- Guardar y organizar recetas  
- Registrar ingredientes  
- Calcular automáticamente el costo total de cada preparación  
- Gestionar precios y márgenes de ganancia  
- Mantener un flujo de trabajo rápido y visual usando **Fluent UI**

---

## 🎨 Interfaz basada en Fluent UI

<a title="Made with Windows Design" href="https://github.com/bdlukaa/fluent_ui">
  <img src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=gray&labelColor=0078D7" />
</a>

La app utiliza **Fluent UI for Flutter**, ofreciendo:

- Acrylic y Mica backgrounds  
- Controles nativos de Windows  
- Animaciones fluidas  
- Tipografía y colores del sistema  

---

## 🛠️ Tecnologías principales

| Área | Tecnología |
|------|------------|
| UI | Fluent UI for Flutter |
| Persistencia | Hive |
| Plataforma | Windows Desktop |
| Instalador | MSIX |

---

## 📦 Generar instalador (MSIX)

```bash
flutter pub run msix:create
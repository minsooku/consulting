import React, { useState } from "react";
import {
  View,
  Text,
  Button,
  ScrollView,
  StyleSheet,
  Alert,
  TouchableOpacity,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

export default function PlanDetailScreen({ route, navigation }) {
  const { plan } = route.params;
  const [viewMode, setViewMode] = useState("daily"); // 'daily' | 'weekly'

  const deletePlan = async () => {
    Alert.alert("Delete Plan", `Are you sure you want to delete "${plan.name}"?`, [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete",
        style: "destructive",
        onPress: async () => {
          try {
            const savedPlans = await AsyncStorage.getItem("plans");
            let plans = savedPlans ? JSON.parse(savedPlans) : [];
            // Filter out the plan with the matching ID
            const newPlans = plans.filter((p) => p.id !== plan.id);
            await AsyncStorage.setItem("plans", JSON.stringify(newPlans));
            // Go back to the list of plans
            navigation.goBack();
          } catch (e) {
            console.error("Error deleting plan:", e);
            Alert.alert("Error", "Could not delete the plan.");
          }
        },
      },
    ]);
  };

  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={{ padding: 16 }}
    >
      <Text style={styles.planTitle}>{plan.name}</Text>

      {/* Navigation bar */}
      <View style={styles.navContainer}>
        {["daily", "weekly"].map((mode) => (
          <TouchableOpacity
            key={mode}
            onPress={() => setViewMode(mode)}
            style={[
              styles.navButton,
              viewMode === mode && styles.navButtonSelected,
            ]}
          >
            <Text style={styles.navButtonText}>{mode.toUpperCase()}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Conditional Content */}
      {viewMode === "daily" && (
        <>
          <Text style={styles.header}>Daily Plans</Text>
          {plan.daily.length === 0 && <Text>No daily plans for this item.</Text>}
          {plan.daily.map((day) => (
            <View key={day.date} style={styles.planBox}>
              <Text style={styles.planDate}>{day.date}</Text>
              {day.blocks.map((block, idx) => (
                <View key={idx} style={styles.blockBox}>
                  <Text style={styles.blockTitle}>{block.title}</Text>
                  <Text>Category: {block.category}</Text>
                  <Text>Duration: {block.duration_min} min</Text>
                  {block.details.map((d, i) => (
                    <Text key={i}>
                      • {d.label}: {d.target_value} {d.unit || ""}
                    </Text>
                  ))}
                </View>
              ))}
            </View>
          ))}
        </>
      )}

      {viewMode === "weekly" && (
        <>
          <Text style={styles.header}>Weekly Plans</Text>
          {plan.weekly.length === 0 && <Text>No weekly plans for this item.</Text>}
          {plan.weekly.map((week) => (
            <View key={week.week_number} style={styles.planBox}>
              <Text style={styles.planDate}>Week {week.week_number}</Text>
              <Text>Theme: {week.theme}</Text>
              <Text>Notes: {week.notes}</Text>
              {week.details.map((d, i) => (
                <Text key={i}>
                  • {d.label}: {d.target_value} {d.unit || ""}
                </Text>
              ))}
            </View>
          ))}
        </>
      )}

      <View style={{ marginTop: 20, marginBottom: 40 }}>
        <Button title="Delete This Plan" color="red" onPress={deletePlan} />
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: { flex: 1 },
  planTitle: { fontSize: 24, fontWeight: "bold", textAlign: "center", marginBottom: 10 },
  header: { fontSize: 20, fontWeight: "bold", marginTop: 16 },
  planBox: { marginVertical: 10, padding: 10, borderWidth: 1, borderRadius: 8, borderColor: '#ccc' },
  planDate: { fontWeight: "bold", marginBottom: 6 },
  blockBox: { marginLeft: 10, marginBottom: 6 },
  blockTitle: { fontWeight: "bold", fontSize: 16 },
  navContainer: {
    flexDirection: "row",
    justifyContent: "center",
    marginBottom: 10,
  },
  navButton: {
    padding: 10,
    marginHorizontal: 5,
    backgroundColor: "gray",
    borderRadius: 6,
  },
  navButtonSelected: {
    backgroundColor: "#00adf5",
  },
  navButtonText: {
    color: "white",
    fontWeight: "bold",
  },
});
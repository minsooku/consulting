import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Button,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useIsFocused } from "@react-navigation/native";

export default function ViewPlanScreen({ navigation }) {
  const [plans, setPlans] = useState([]);
  const isFocused = useIsFocused(); // This hook reloads data when the screen is focused

  useEffect(() => {
    if (isFocused) {
      loadSavedPlans();
    }
  }, [isFocused]);

  const loadSavedPlans = async () => {
    try {
      const savedPlans = await AsyncStorage.getItem("plans");
      setPlans(savedPlans ? JSON.parse(savedPlans) : []);
    } catch (e) {
      console.error("Error loading saved plans:", e);
    }
  };

  // ✅ 특정 plan 삭제
  const deletePlan = async (id) => {
    try {
      const updatedPlans = plans.filter((plan) => plan.id !== id);
      setPlans(updatedPlans);
      await AsyncStorage.setItem("plans", JSON.stringify(updatedPlans));
    } catch (e) {
      console.error("Error deleting plan:", e);
    }
  };

  const renderPlanItem = ({ item }) => {
    return (
      <View style={styles.planBox}>
        {/* 터치 시 상세 페이지 이동 */}
        <TouchableOpacity
          style={{ flex: 1 }}
          onPress={() =>
            navigation.navigate("PlanDetailScreen", { plan: item })
          }
        >
          <Text style={styles.planName}>{item.name}</Text>
        </TouchableOpacity>

        {/* 삭제 버튼 */}
        <TouchableOpacity
          style={styles.deleteButton}
          onPress={() => deletePlan(item.id)}
        >
          <Text style={{ color: "white", fontWeight: "bold" }}>Delete</Text>
        </TouchableOpacity>
      </View>
    );
  };

  return (
    <FlatList
      data={plans}
      renderItem={renderPlanItem}
      keyExtractor={(item, index) => item.id?.toString() ?? index.toString()}
      contentContainerStyle={{ padding: 16 }}
      ListEmptyComponent={
        <Text style={{ textAlign: "center", marginTop: 20 }}>
          No saved plans yet.
        </Text>
      }
    />
  );
}

const styles = StyleSheet.create({
  planBox: {
    flexDirection: "row", // 가로 배치
    alignItems: "center",
    justifyContent: "space-between",
    marginVertical: 8,
    padding: 20,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: "#ccc",
    backgroundColor: "#f9f9f9",
  },
  planName: {
    fontSize: 18,
    fontWeight: "bold",
  },
  deleteButton: {
    marginLeft: 10,
    backgroundColor: "red",
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 6,
  },
});

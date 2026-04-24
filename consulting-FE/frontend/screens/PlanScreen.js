// frontend/screens/PlanScreen.js
import React, { useState } from "react";
import {
  View,
  Text,
  Button,
  StyleSheet,
  Alert,
  TextInput,
  ActivityIndicator,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

export default function PlanScreen({ navigation }) {
  const [planName, setPlanName] = useState("");
  const [loading, setLoading] = useState(false); // ✅ 로딩 상태

  const fetchAndSavePlan = async () => {
    try {
      setLoading(true); // ✅ 로딩 시작

      const storedPayload = await AsyncStorage.getItem("payload");
      if (!storedPayload) {
        Alert.alert("No payload found", "Please create a payload first.");
        setLoading(false);
        return;
      }

      if (!planName.trim()) {
        Alert.alert("Missing Name", "Please enter a name for this plan.");
        setLoading(false);
        return;
      }

      const response = await fetch("http://127.0.0.1:8000/test", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: storedPayload,
      });

      if (!response.ok) throw new Error(`Error ${response.status}`);

      const data = await response.json();
      console.log("Received plan:", data);

      const existingPlansStr = await AsyncStorage.getItem("plans");
      const existingPlans = existingPlansStr ? JSON.parse(existingPlansStr) : [];

      const newPlan = {
        id: Date.now().toString(),
        name: planName,
        daily: data.daily || [],
        weekly: data.weekly || [],
      };

      const updatedPlans = [...existingPlans, newPlan];
      await AsyncStorage.setItem("plans", JSON.stringify(updatedPlans));

      // ✅ 성공 시 홈 화면으로 이동
      Alert.alert("Success", `Plan "${planName}" was saved!`, [
        { text: "OK", onPress: () => navigation.navigate("RegisterScreen") },
      ]);
    } catch (e) {
      console.error("Error fetching from backend:", e);
      Alert.alert("Error", e.message);
    } finally {
      setLoading(false); // ✅ 로딩 끝
    }
  };

  return (
    <View style={styles.container}>
      {loading ? (
        // ✅ 로딩 표시
        <View style={styles.loadingBox}>
          <ActivityIndicator size="large" color="#0000ff" />
          <Text style={{ marginTop: 10, fontSize: 16 }}>
            Generating plans for you...
          </Text>
        </View>
      ) : (
        <>
          <Text style={styles.label}>Enter a name for your new plan:</Text>
          <TextInput
            style={styles.input}
            placeholder="e.g., Marathon Prep Week 1"
            value={planName}
            onChangeText={setPlanName}
          />
          <Button title="Generate and Save Plan" onPress={fetchAndSavePlan} />
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center" },
  label: { fontSize: 16, marginBottom: 10 },
  input: {
    height: 40,
    borderColor: "gray",
    borderWidth: 1,
    width: "80%",
    marginBottom: 20,
    paddingHorizontal: 10,
  },
  loadingBox: {
    alignItems: "center",
    justifyContent: "center",
  },
});

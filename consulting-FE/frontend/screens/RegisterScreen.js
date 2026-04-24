// frontend/screens/RegisterScreen.js
import React from "react";
import { View, Text, Button, StyleSheet } from "react-native";

export default function RegisterScreen({ navigation }) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome!</Text>

      {/* Navigate to PayloadFormScreen instead of PlanScreen */}
      <Button
        title="Add Plans"
        onPress={() => navigation.navigate("PayloadFormScreen")}
      />

      <View style={{ marginTop: 20 }}>
        <Button
          title="View Plans"
          onPress={() => navigation.navigate("ViewPlanScreen")}
        />
      </View>

      <View style={{ marginTop: 20}}>
        <Button
          title="Calendar"
          onPress={() => navigation.navigate("CalendarChecklist")}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center" },
  title: { fontSize: 22, marginBottom: 20 },
});

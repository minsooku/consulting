import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import RegisterScreen from "./screens/RegisterScreen";
import PlanScreen from "./screens/PlanScreen";
import ViewPlanScreen from "./screens/ViewPlanScreen";
import PayloadFormScreen from "./screens/PayloadFormScreen";
import PlanDetailScreen from "./screens/PlanDetailScreen";
import CalendarChecklist from "./screens/CalendarChecklist";

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="RegisterScreen">
        <Stack.Screen name="RegisterScreen" component={RegisterScreen} options={{ title: "Home" }} />
        <Stack.Screen name="PayloadFormScreen" component={PayloadFormScreen} options={{ title: "Build Payload" }} />
        <Stack.Screen name="PlanScreen" component={PlanScreen} options={{ title: "Add Plans" }} />
        <Stack.Screen name="ViewPlanScreen" component={ViewPlanScreen} options={{ title: "My Saved Plans" }} />
        <Stack.Screen name="PlanDetailScreen" component={PlanDetailScreen} options={({ route }) => ({ title: route.params.plan.name })} />
        <Stack.Screen name="CalendarChecklist" component={CalendarChecklist} options={{ title: "Calendar"}} />
      </Stack.Navigator>
    </NavigationContainer>
  );
} 
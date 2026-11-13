import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider } from "./shared/auth/AuthProvider";
import { AppShell } from "./shared/ui/AppShell";
import { ProtectedRoute } from "./shared/ui/ProtectedRoute";
import { FarmSettingsPage } from "./features/auth/pages/FarmSettingsPage";
import { ProfilePage } from "./features/auth/pages/ProfilePage";
import { SignInPage } from "./features/auth/pages/SignInPage";
import { SignUpPage } from "./features/auth/pages/SignUpPage";
import { DashboardPage } from "./features/dashboard/pages/DashboardPage";
import { CowCreatePage } from "./features/cows/pages/CowCreatePage";
import { CowDetailPage } from "./features/cows/pages/CowDetailPage";
import { CowsListPage } from "./features/cows/pages/CowsListPage";
import { CropCycleCreatePage } from "./features/crops/pages/CropCycleCreatePage";
import { CropCycleDetailPage } from "./features/crops/pages/CropCycleDetailPage";
import { CropCyclesListPage } from "./features/crops/pages/CropCyclesListPage";
import { CropNameCreatePage } from "./features/crops/pages/CropNameCreatePage";
import { CropNameDetailPage } from "./features/crops/pages/CropNameDetailPage";
import { CropNamesListPage } from "./features/crops/pages/CropNamesListPage";
import { LedgerCreatePage } from "./features/income-expenses/pages/LedgerCreatePage";
import { LedgerDetailPage } from "./features/income-expenses/pages/LedgerDetailPage";
import { LedgerListPage } from "./features/income-expenses/pages/LedgerListPage";
import { InventoryCreatePage } from "./features/inventory/pages/InventoryCreatePage";
import { InventoryDetailPage } from "./features/inventory/pages/InventoryDetailPage";
import { InventoryListPage } from "./features/inventory/pages/InventoryListPage";
import { PoultryCreatePage } from "./features/poultry/pages/PoultryCreatePage";
import { PoultryDetailPage } from "./features/poultry/pages/PoultryDetailPage";
import { PoultryListPage } from "./features/poultry/pages/PoultryListPage";

const queryClient = new QueryClient();

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/signin" element={<SignInPage />} />
            <Route path="/signup" element={<SignUpPage />} />
            <Route element={<ProtectedRoute />}>
              <Route element={<AppShell />}>
                <Route path="/" element={<Navigate to="/dashboard" replace />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/cows" element={<CowsListPage />} />
                <Route path="/cows/new" element={<CowCreatePage />} />
                <Route path="/cows/:cowId" element={<CowDetailPage />} />
                <Route path="/poultry" element={<PoultryListPage />} />
                <Route path="/poultry/new" element={<PoultryCreatePage />} />
                <Route
                  path="/poultry/:groupId"
                  element={<PoultryDetailPage />}
                />
                <Route path="/crops" element={<CropCyclesListPage />} />
                <Route path="/crops/names" element={<CropNamesListPage />} />
                <Route
                  path="/crops/names/new"
                  element={<CropNameCreatePage />}
                />
                <Route
                  path="/crops/names/:cropNameId"
                  element={<CropNameDetailPage />}
                />
                <Route
                  path="/crops/cycles/new"
                  element={<CropCycleCreatePage />}
                />
                <Route
                  path="/crops/cycles/:cycleId"
                  element={<CropCycleDetailPage />}
                />
                <Route path="/inventory" element={<InventoryListPage />} />
                <Route
                  path="/inventory/new"
                  element={<InventoryCreatePage />}
                />
                <Route
                  path="/inventory/:itemId"
                  element={<InventoryDetailPage />}
                />
                <Route path="/ledger" element={<LedgerListPage />} />
                <Route path="/ledger/new" element={<LedgerCreatePage />} />
                <Route path="/ledger/:entryId" element={<LedgerDetailPage />} />
                <Route path="/profile" element={<ProfilePage />} />
                <Route path="/settings" element={<FarmSettingsPage />} />
              </Route>
            </Route>
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  );
}

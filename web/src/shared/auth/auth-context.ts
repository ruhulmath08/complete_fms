import { createContext } from "react";

export type AuthContextValue = {
  isSignedIn: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  markSignedOut: () => void;
};

export const AuthContext = createContext<AuthContextValue | null>(null);

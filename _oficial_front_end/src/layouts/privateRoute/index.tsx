import { useUserSession } from "@/providers";
import { Navigate, Outlet } from "react-router-dom";

export function PrivateRoute() {
    const { isAuth } = useUserSession();

    // if (!isAuth) {
    //     return <Navigate to="/login" replace />;
    // }

    return <Outlet />;
}
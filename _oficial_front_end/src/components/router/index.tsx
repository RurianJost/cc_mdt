import { AppLayout, PrivateRoute } from '@/layouts/';
import { Home, Registers, OccurrenceData, ToRegister, Officers, Communications, Fines } from '@/modules';
import {
    Route,
    Routes
} from 'react-router-dom';

export function Router(): JSX.Element {
    return (
        <Routes>
            <Route element={<AppLayout />}>
                <Route path="/login" element={<></>} />
                <Route element={<PrivateRoute />}>
                    <Route path="/" element={<Home />} />
                    <Route path="/registers" element={<Registers />} />
                    <Route path="/data" element={<OccurrenceData />} />
                    <Route path="/toRegister" element={<ToRegister />} />
                    <Route path="/officers" element={<Officers />} />
                    <Route path="/communications" element={<Communications />} />
                    <Route path="/fines" element={<Fines />} />
                </Route>
            </Route>
        </Routes>
    );
}
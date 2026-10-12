'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/authStore';

export default function Home() {
  const router = useRouter();
  const { token, usuario, hydrated } = useAuthStore();

  useEffect(() => {
    if (!hydrated) return;
    if (token) {
      const destino = usuario?.rol === 'SUPERADMIN' ? '/superadmin'
        : ['ADMIN_EMPRESA', 'GERENTE'].includes(usuario?.rol || '') ? '/dashboard'
        : usuario?.rol === 'COCINERO' ? '/cocina'
        : usuario?.rol === 'DOMICILIARIO' ? '/domicilios' : '/pos';
      router.replace(destino);
    } else {
      router.push('/login');
    }
  }, [token, usuario, hydrated, router]);

  return null;
}

'use client';

import { useState } from 'react';

export default function LookerDashboard() {
  const [revision, setRevision] = useState(0);
  const configured = process.env.NEXT_PUBLIC_LOOKER_EMBED_URL;
  let reportUrl: string | undefined;
  try {
    const url = new URL(configured || '');
    if (url.protocol === 'https:' && ['lookerstudio.google.com', 'datastudio.google.com'].includes(url.hostname) && /^\/embed\/reporting\/[a-zA-Z0-9-]+(?:\/|$)/.test(url.pathname)) {
      reportUrl = url.toString();
    }
  } catch { /* El informe se configura desde el entorno. */ }

  return (
    <section aria-labelledby="looker-title" className="min-w-0 overflow-hidden rounded-xl border border-gray-800 bg-gray-900">
      <div className="flex flex-wrap items-center justify-between gap-3 border-b border-gray-800 p-4">
        <div>
          <h2 id="looker-title" className="font-semibold text-white">Analítica empresarial</h2>
          <p className="mt-1 text-sm text-gray-400">Ventas, productos y formas de pago · Looker Studio</p>
        </div>
        {reportUrl && <div className="flex gap-3 text-sm">
          <button type="button" onClick={() => setRevision(r => r + 1)} className="rounded-lg border border-gray-700 px-3 py-2 text-gray-200 hover:bg-gray-800">Recargar informe</button>
          <a href={reportUrl.replace('/embed/reporting/', '/reporting/')} target="_blank" rel="noopener noreferrer" className="rounded-lg bg-orange-600 px-3 py-2 text-white hover:bg-orange-500">Abrir informe</a>
        </div>}
      </div>
      {reportUrl ? <>
        <div className="h-[75vh] min-h-[560px] w-full md:aspect-[16/10] md:h-auto">
          <iframe key={revision} src={reportUrl} title="Dashboard interactivo de ventas PowerPOS en Looker Studio" className="h-full w-full border-0" allowFullScreen referrerPolicy="strict-origin-when-cross-origin" />
        </div>
        <p className="px-4 py-3 text-xs text-gray-400">Usa los controles de fecha y categoría del informe. Los datos se actualizan según la configuración de frescura de Looker Studio.</p>
      </> : <div className="p-8 text-center text-gray-300">
        <p>El informe de analítica todavía no está disponible.</p>
        <p className="mt-2 text-sm text-gray-500">Mientras se habilita, puedes consultar los indicadores operativos de esta página.</p>
      </div>}
    </section>
  );
}

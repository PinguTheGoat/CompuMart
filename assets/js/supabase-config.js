/**
 * CompuMart Supabase Cloud Configuration
 * When hosting on Vercel or running without local PHP/XAMPP,
 * insert your Supabase project credentials below.
 */
const SUPABASE_CONFIG = {
  url: "https://your-project-id.supabase.co",
  anonKey: "your-anon-key-here"
};

// Client-side helper to fetch products directly from Supabase REST API
async function fetchSupabaseProducts() {
  if (SUPABASE_CONFIG.url.includes("your-project-id")) {
    console.log("Using local warehouse fallback catalog");
    return null;
  }
  try {
    const res = await fetch(`${SUPABASE_CONFIG.url}/rest/v1/products?select=*`, {
      headers: {
        "apikey": SUPABASE_CONFIG.anonKey,
        "Authorization": `Bearer ${SUPABASE_CONFIG.anonKey}`
      }
    });
    if (!res.ok) throw new Error("Failed to fetch products from Supabase");
    return await res.json();
  } catch (err) {
    console.error("Supabase fetch error:", err);
    return null;
  }
}

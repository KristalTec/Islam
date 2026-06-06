// =====================================================
// Islam Online - Cloudflare Worker (Claude AI Backend)
// =====================================================
// Deploy this at: https://dash.cloudflare.com → Workers
// Worker name: islam-online-ai
// Add secret: ANTHROPIC_API_KEY = sk-ant-...
// =====================================================

export default {
  async fetch(request, env) {
    // CORS headers — required for browser requests
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    // Handle preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    if (request.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405, headers: corsHeaders });
    }

    try {
      const body = await request.json();
      const userPrompt = body.prompt || "بنووسە یەک فەرموودەی ئیسلامی بە کوردی سۆرانی.";

      // Call Claude claude-sonnet-4-20250514 via Anthropic API
      const claudeRes = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": env.ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: "claude-sonnet-4-20250514",
          max_tokens: 300,
          system: `تۆ یاریدەدەری ئیسلامی بەکارهێنەری ماڵپەڕی Islam Online ی. 
وەڵامەکانت بە کوردی سۆرانی بدەرەوە تەنها ئەگەر داواکاریەکە کوردی بێت.
تەنها ناوەڕۆکی داواکراو بنووسە. بێ پێشەکی، بێ ڕووناکبیرییەکی زیادە.
ناوەڕۆکەکە دەبێت یاریدەدەرانە، باش، و ئیسلامی بێت.`,
          messages: [
            { role: "user", content: userPrompt }
          ],
        }),
      });

      if (!claudeRes.ok) {
        const errText = await claudeRes.text();
        return new Response(
          JSON.stringify({ error: "Claude API error", details: errText }),
          { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const claudeData = await claudeRes.json();
      const content = claudeData.content?.[0]?.text || "";

      return new Response(
        JSON.stringify({ content }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );

    } catch (e) {
      return new Response(
        JSON.stringify({ error: "Worker error", details: e.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
  },
};

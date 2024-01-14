export const getAddressAutoComplete = async (query: string) => {
  if (query === "") {
    return [];
  }

  const API_KEY = process.env.GEOAPIFY_API_KEY ?? "";
  const url = `https://api.geoapify.com/v1/geocode/autocomplete?text=${encodeURIComponent(
    query
  )}&apiKey=${API_KEY}`;

  try {
    const response = await fetch(url);

    if (response.status === 200) {
      return await response.json();
    } else {
      console.error("Failed address response: ", response.status);
      throw new Error("Failed to load addresses");
    }
  } catch (error) {
    console.error("Error during address search:", error);
    throw error;
  }
};

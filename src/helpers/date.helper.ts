export const isValidDate = (dateString: string): boolean => {
  const date = dateString.includes(".")
    ? new Date(dateString.split(".").reverse().join("-"))
    : new Date(dateString);
  return date.toString() !== "Invalid Date" && !isNaN(date.getTime());
};

export const isAdult = (dateString: string): boolean => {
    const today = new Date();
    const birthDate = new Date(
      dateString.includes(".")
        ? dateString.split(".").reverse().join("-")
        : dateString
    );
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
    return age >= 14;
  };
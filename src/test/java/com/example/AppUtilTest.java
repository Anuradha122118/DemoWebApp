
package com.example;

import org.junit.Test;
import static org.junit.Assert.*;

public class AppUtilTest {

    private final AppUtil appUtil = new AppUtil();

    @Test
    public void testAdd() {
        assertEquals(5, appUtil.add(2, 3));
        assertEquals(0, appUtil.add(-2, 2));
    }

    @Test
    public void testIsPositive() {
        assertTrue(appUtil.isPositive(5));
        assertFalse(appUtil.isPositive(0));
        assertFalse(appUtil.isPositive(-5));
    }

    @Test
    public void testGreetWithName() {
        assertEquals("Hello, Anu!", appUtil.greet("Anu"));
        assertEquals("Hello, Anu!", appUtil.greet("  Anu  "));
    }

    @Test
    public void testGreetWithEmptyName() {
        assertEquals("Hello, Guest!", appUtil.greet(""));
        assertEquals("Hello, Guest!", appUtil.greet("   "));
        assertEquals("Hello, Guest!", appUtil.greet(null));
    }
}
